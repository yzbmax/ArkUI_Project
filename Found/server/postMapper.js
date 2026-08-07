/**
 * post 行 → 前端结构 映射（批量作者/点赞/收藏查询，避免 N+1 过重）
 */
const { query } = require('./db');
const { relativeTime, parseJson, creditLevel } = require('./utils');

function rowToPost(r, u, liked, collected) {
  const pending = r.audit_status === 'pending';
  const credit = (u && u.credit_score) || 0;
  return {
    id: r.id,
    userId: r.user_id,
    type: r.type,
    title: r.title,
    desc: r.description,
    category: r.category,
    categoryName: r.category_name,
    location: r.location,
    time: relativeTime(r.occurred_at || r.created_at),
    images: parseJson(r.images, []),
    contact: r.contact,
    verifyQuestion: r.verify_question,
    anonymous: !!r.is_anonymous,
    urgent: r.urgency === 'urgent',
    reward: r.reward,
    status: pending ? 'pending' : r.status,
    rejectReason: r.audit_remark || '',
    author: r.is_anonymous ? '匿名用户' : ((u && u.nickname) || '热心同学'),
    authorAvatar: (u && u.avatar) || '',
    creditLevel: creditLevel(credit),
    likes: r.like_count,
    comments: r.comment_count,
    liked: !!liked,
    collected: !!collected
  };
}

/** 多行 → 前端结构（uid 提供时计算当前用户的点赞/收藏态） */
async function rowsToPosts(rows, uid) {
  if (!rows || rows.length === 0) return [];
  const uids = [...new Set(rows.map((r) => r.user_id))];
  const ph = uids.map(() => '?').join(',');
  const userRows = await query(`SELECT id, nickname, avatar, credit_score FROM \`user\` WHERE id IN (${ph})`, uids);
  const userMap = new Map(userRows.map((u) => [u.id, u]));

  let likedSet = new Set();
  let collectedSet = new Set();
  if (uid) {
    const ids = rows.map((r) => r.id);
    const idPh = ids.map(() => '?').join(',');
    const lRows = await query(`SELECT target_id FROM \`like\` WHERE user_id=? AND target_type='post' AND target_id IN (${idPh})`, [uid, ...ids]);
    likedSet = new Set(lRows.map((r) => r.target_id));
    const cRows = await query(`SELECT post_id FROM collect WHERE user_id=? AND post_id IN (${idPh})`, [uid, ...ids]);
    collectedSet = new Set(cRows.map((r) => r.post_id));
  }
  return rows.map((r) => rowToPost(r, userMap.get(r.user_id), likedSet.has(r.id), collectedSet.has(r.id)));
}

/** 评论加载：顶层 + 一层回复（楼中楼） */
async function loadComments(postId) {
  const tops = await query(
    `SELECT c.*, u.nickname, u.avatar FROM comment c JOIN \`user\` u ON c.user_id=u.id
     WHERE c.post_id=? AND c.parent_id IS NULL AND c.status='normal' ORDER BY c.created_at ASC`, [postId]);
  const replies = await query(
    `SELECT c.*, u.nickname, u.avatar, ru.nickname AS reply_to_name
     FROM comment c JOIN \`user\` u ON c.user_id=u.id LEFT JOIN \`user\` ru ON c.reply_to_user_id=ru.id
     WHERE c.post_id=? AND c.parent_id IS NOT NULL AND c.status='normal' ORDER BY c.created_at ASC`, [postId]);
  const replyMap = new Map();
  for (const r of replies) {
    const arr = replyMap.get(r.parent_id) || [];
    arr.push(r);
    replyMap.set(r.parent_id, arr);
  }
  return tops.map((t) => ({
    id: t.id,
    userId: t.user_id,
    author: t.nickname,
    avatar: t.avatar || '',
    content: t.content,
    time: relativeTime(t.created_at),
    replyTo: '',
    replies: (replyMap.get(t.id) || []).map((rr) => ({
      id: rr.id,
      userId: rr.user_id,
      author: rr.nickname,
      avatar: rr.avatar || '',
      content: rr.content,
      time: relativeTime(rr.created_at),
      replyTo: rr.reply_to_name || '',
      replies: []
    }))
  }));
}

module.exports = { rowToPost, rowsToPosts, loadComments };
