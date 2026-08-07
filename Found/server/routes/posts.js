/**
 * 动态路由：列表 / 详情 / 创建 / 点赞 / 收藏 / 关闭 / 评论 / 举报
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, uuid, pageParams } = require('../utils');
const { requireAuth } = require('../auth');
const { rowsToPosts, loadComments } = require('../postMapper');

// 动态列表（分页 + 组合筛选）
router.get('/', async (req, res) => {
  const { type, category, keyword, urgent, status, includePending, sort } = req.query;
  const { page, size, offset } = pageParams(req.query);
  const where = [];
  const params = [];
  if (includePending !== '1') {
    // 仅公开已审核通过的内容；待审核/被驳回均不对外
    where.push("audit_status = 'approved'");
  }
  if (type) { where.push('type = ?'); params.push(type); }
  if (category) { where.push('category = ?'); params.push(category); }
  if (status) { where.push('status = ?'); params.push(status); }
  else {
    // 默认不展示已完结动态（已归还/已关闭），显式传 status 时可查
    where.push("status NOT IN ('resolved','closed')");
  }
  if (urgent === '1' || urgent === 'true') { where.push("urgency = 'urgent'"); }
  if (keyword) {
    const kws = String(keyword).trim().split(/\s+/).filter((s) => s.length);
    for (const kw of kws) {
      where.push('(title LIKE ? OR description LIKE ? OR location LIKE ?)');
      const like = '%' + kw + '%';
      params.push(like, like, like);
    }
  }
  const whereSql = where.length ? 'WHERE ' + where.join(' AND ') : '';
  const orderSql = sort === 'urgent' ? "ORDER BY (urgency='urgent') DESC, created_at DESC" : 'ORDER BY created_at DESC';

  const cntRows = await query(`SELECT COUNT(*) AS c FROM post ${whereSql}`, params);
  const total = cntRows[0].c;
  const rows = await query(`SELECT * FROM post ${whereSql} ${orderSql} LIMIT ? OFFSET ?`, [...params, size, offset]);
  const uid = req.user ? req.user.uid : null;
  const list = await rowsToPosts(rows, uid);
  ok(res, { list, total, page, size, hasMore: offset + rows.length < total });
});

// 动态详情（含评论）
router.get('/:id', async (req, res) => {
  const rows = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  await query('UPDATE post SET view_count = view_count + 1 WHERE id = ?', [req.params.id]);
  const uid = req.user ? req.user.uid : null;
  const list = await rowsToPosts(rows, uid);
  const post = list[0];
  post.commentList = await loadComments(post.id);
  ok(res, post);
});

// 创建（进审核）
router.post('/', requireAuth, async (req, res) => {
  const b = req.body || {};
  const { type, title, desc, category, categoryName, location, contact, verifyQuestion, anonymous, urgent, reward, images } = b;
  if (!type || !title || !desc || !category) return fail(res, 1, '类型、名称、描述、分类必填');
  const id = uuid();
  const now = new Date();
  await query(
    'INSERT INTO post (id, user_id, type, category, category_name, title, description, images, location, contact, verify_question, is_anonymous, urgency, reward, status, audit_status, occurred_at, created_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
    [id, req.user.uid, type, category, categoryName || '', title, desc, JSON.stringify(Array.isArray(images) ? images : []),
      location || '', contact || '', verifyQuestion || '', anonymous ? 1 : 0, urgent ? 'urgent' : 'normal', reward || '',
      'pending', 'pending', now, now]
  );
  // 发布 +5 分
  const me = await query('SELECT credit_score FROM `user` WHERE id = ?', [req.user.uid]);
  const balance = (me[0] && me[0].credit_score) || 0;
  await query('UPDATE `user` SET credit_score = credit_score + 5 WHERE id = ?', [req.user.uid]);
  await query('INSERT INTO credit_log (id, user_id, `change`, event_type, description, balance) VALUES (?,?,?,?,?,?)',
    [uuid(), req.user.uid, 5, 'post', '发布动态', balance + 5]);

  const rows = await query('SELECT * FROM post WHERE id = ?', [id]);
  const list = await rowsToPosts(rows, req.user.uid);
  ok(res, list[0], '已提交，等待审核');
});

// 点赞 toggle
router.post('/:id/like', requireAuth, async (req, res) => {
  const rows = await query('SELECT id FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  const l = await query('SELECT id FROM `like` WHERE user_id=? AND target_id=? AND target_type=?', [req.user.uid, req.params.id, 'post']);
  let liked;
  if (l.length > 0) {
    await query('DELETE FROM `like` WHERE id = ?', [l[0].id]);
    await query('UPDATE post SET like_count = GREATEST(0, like_count - 1) WHERE id = ?', [req.params.id]);
    liked = false;
  } else {
    await query('INSERT INTO `like` (id, user_id, target_id, target_type) VALUES (?,?,?,?)', [uuid(), req.user.uid, req.params.id, 'post']);
    await query('UPDATE post SET like_count = like_count + 1 WHERE id = ?', [req.params.id]);
    liked = true;
  }
  const p = await query('SELECT like_count FROM post WHERE id = ?', [req.params.id]);
  ok(res, { liked, likeCount: p[0].like_count });
});

// 收藏 toggle
router.post('/:id/collect', requireAuth, async (req, res) => {
  const rows = await query('SELECT id FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  const c = await query('SELECT id FROM collect WHERE user_id=? AND post_id=?', [req.user.uid, req.params.id]);
  let collected;
  if (c.length > 0) {
    await query('DELETE FROM collect WHERE id = ?', [c[0].id]);
    collected = false;
  } else {
    await query('INSERT INTO collect (id, user_id, post_id) VALUES (?,?,?)', [uuid(), req.user.uid, req.params.id]);
    collected = true;
  }
  ok(res, { collected });
});

// 关闭（仅发布者本人）
router.post('/:id/close', requireAuth, async (req, res) => {
  const rows = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  if (rows[0].user_id !== req.user.uid) return fail(res, 403, '只能关闭自己的动态', 403);
  await query('UPDATE post SET status = ? WHERE id = ?', ['closed', req.params.id]);
  const updated = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  const list = await rowsToPosts(updated, req.user.uid);
  ok(res, list[0]);
});

// 标记已归还（仅发布者本人）
router.post('/:id/resolve', requireAuth, async (req, res) => {
  const rows = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  if (rows[0].user_id !== req.user.uid) return fail(res, 403, '只能操作自己的动态', 403);
  await query("UPDATE post SET status = 'resolved' WHERE id = ?", [req.params.id]);
  const updated = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  const list = await rowsToPosts(updated, req.user.uid);
  ok(res, list[0], '已标记为已归还');
});

// 评论列表
router.get('/:id/comments', async (req, res) => {
  ok(res, await loadComments(req.params.id));
});

// 发表评论（楼中楼最多 2 层）
router.post('/:id/comments', requireAuth, async (req, res) => {
  const { content, parentId, replyToUserId } = req.body || {};
  if (!content || !String(content).trim()) return fail(res, 1, '评论内容不能为空');
  if (String(content).length > 200) return fail(res, 1, '评论最多 200 字');
  const post = await query('SELECT id FROM post WHERE id = ?', [req.params.id]);
  if (post.length === 0) return fail(res, 404, '动态不存在', 404);
  if (parentId) {
    const parent = await query('SELECT parent_id FROM comment WHERE id = ?', [parentId]);
    if (parent.length === 0) return fail(res, 404, '被回复的评论不存在', 404);
    if (parent[0].parent_id) return fail(res, 1, '仅支持两层楼中楼');
  }
  const id = uuid();
  await query(
    'INSERT INTO comment (id, post_id, user_id, content, parent_id, reply_to_user_id) VALUES (?,?,?,?,?,?)',
    [id, req.params.id, req.user.uid, String(content).trim(), parentId || null, replyToUserId || null]
  );
  await query('UPDATE post SET comment_count = comment_count + 1 WHERE id = ?', [req.params.id]);
  const rows = await query(
    'SELECT c.*, u.nickname, ru.nickname AS reply_to_name FROM comment c JOIN `user` u ON c.user_id=u.id LEFT JOIN `user` ru ON c.reply_to_user_id=ru.id WHERE c.id = ?',
    [id]
  );
  const c = rows[0];
  ok(res, {
    id: c.id, userId: c.user_id, author: c.nickname, avatar: c.avatar || '', content: c.content,
    time: require('../utils').relativeTime(c.created_at), replyTo: c.reply_to_name || '', replies: []
  });
});

// 举报
router.post('/:id/report', requireAuth, async (req, res) => {
  const { reason, description } = req.body || {};
  if (!reason) return fail(res, 1, '举报类型必填');
  const post = await query('SELECT id FROM post WHERE id = ?', [req.params.id]);
  if (post.length === 0) return fail(res, 404, '动态不存在', 404);
  await query(
    'INSERT INTO report (id, reporter_id, target_id, target_type, reason, description) VALUES (?,?,?,?,?,?)',
    [uuid(), req.user.uid, req.params.id, 'post', reason, description || '']
  );
  ok(res, { ok: true }, '举报已提交');
});

module.exports = router;
