/**
 * 消息中心通知（C502）—— 从真实业务表派生三类通知：
 * - system：我的动态审核结果 + 我的积分变动
 * - interact：评论 / 认领申请 / 线索 / 点赞（发生在我发布的动态上）
 * - match：我发布的寻物 ↔ 失物（同分类）互相匹配提醒
 * 已读状态记录在 notif_read 表（PUT /:type/read 标记）。
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, relativeTime } = require('../utils');
const { requireAuth } = require('../auth');

const TYPES = ['system', 'match', 'interact'];

async function readAt(uid, type) {
  const rows = await query('SELECT read_at FROM notif_read WHERE user_id = ? AND type = ?', [uid, type]);
  return rows.length ? rows[0].read_at : null;
}

/** 组一条通知：7 天内且晚于已读时间 → 未读 */
function item(id, type, title, content, createdAt, readAt) {
  const t = new Date(createdAt).getTime();
  const unread = readAt ? t > new Date(readAt).getTime() : (Date.now() - t) < 7 * 86400000;
  return { id, type, title, content, time: relativeTime(createdAt), unread: !!unread };
}

// 我的三类通知
router.get('/', requireAuth, async (req, res) => {
  const uid = req.user.uid;

  /* ---------- system：审核结果 + 积分变动 ---------- */
  const sysRead = await readAt(uid, 'system');
  const system = [];
  const audits = await query(
    "SELECT p.id AS pid, p.title, p.audit_status, p.audit_remark, p.updated_at FROM post p " +
    "WHERE p.user_id = ? AND p.audit_status IN ('approved','rejected') ORDER BY p.updated_at DESC LIMIT 20",
    [uid]);
  audits.forEach((a) => {
    const content = a.audit_status === 'approved'
      ? '你的动态《' + a.title + '》已通过审核，发布上线'
      : '你的动态《' + a.title + '》未通过审核' + (a.audit_remark ? '：' + a.audit_remark : '');
    system.push(item('sys-a-' + a.pid, 'system', '审核结果', content, a.updated_at, sysRead));
  });
  const creds = await query(
    'SELECT id, description, `change`, created_at FROM credit_log WHERE user_id = ? ORDER BY created_at DESC LIMIT 10',
    [uid]);
  creds.forEach((c) => {
    system.push(item('sys-c-' + c.id, 'system', '积分变动',
      c.description + ' ' + (c.change >= 0 ? '+' : '') + c.change + ' 分', c.created_at, sysRead));
  });

  /* ---------- interact：评论 / 认领 / 线索 / 点赞 ---------- */
  const itRead = await readAt(uid, 'interact');
  const interact = [];
  const comments = await query(
    'SELECT c.id, c.content, c.created_at, p.title, u.nickname FROM comment c ' +
    'JOIN post p ON c.post_id = p.id JOIN `user` u ON c.user_id = u.id ' +
    'WHERE p.user_id = ? AND c.user_id <> ? ORDER BY c.created_at DESC LIMIT 20',
    [uid, uid]);
  comments.forEach((c) => interact.push(
    item('it-c-' + c.id, 'interact', '评论', c.nickname + ' 评论了你的《' + c.title + '》：' + c.content, c.created_at, itRead)));
  const clm = await query(
    'SELECT c.id, c.created_at, p.title, u.nickname FROM claim c ' +
    'JOIN post p ON c.post_id = p.id JOIN `user` u ON c.claimant_id = u.id ' +
    'WHERE p.user_id = ? AND c.claimant_id <> ? ORDER BY c.created_at DESC LIMIT 20',
    [uid, uid]);
  clm.forEach((c) => interact.push(
    item('it-cl-' + c.id, 'interact', '认领申请', c.nickname + ' 申请认领你的《' + c.title + '》', c.created_at, itRead)));
  const clu = await query(
    'SELECT c.id, c.created_at, p.title, u.nickname FROM clue c ' +
    'JOIN post p ON c.post_id = p.id JOIN `user` u ON c.provider_id = u.id ' +
    'WHERE p.user_id = ? AND c.provider_id <> ? ORDER BY c.created_at DESC LIMIT 20',
    [uid, uid]);
  clu.forEach((c) => interact.push(
    item('it-clu-' + c.id, 'interact', '新线索', c.nickname + ' 为你的《' + c.title + '》提供了线索', c.created_at, itRead)));
  const likes = await query(
    'SELECT l.id, l.created_at, p.title, u.nickname FROM `like` l ' +
    'JOIN post p ON l.target_id = p.id AND l.target_type = \'post\' JOIN `user` u ON l.user_id = u.id ' +
    'WHERE p.user_id = ? AND l.user_id <> ? ORDER BY l.created_at DESC LIMIT 20',
    [uid, uid]);
  likes.forEach((l) => interact.push(
    item('it-l-' + l.id, 'interact', '点赞', l.nickname + ' 赞了你的《' + l.title + '》', l.created_at, itRead)));

  /* ---------- match：同分类 寻物↔失物 双向匹配 ---------- */
  const mtRead = await readAt(uid, 'match');
  const match = [];
  const myPosts = await query(
    "SELECT id, title, category, type FROM post WHERE user_id = ? AND audit_status = 'approved' AND status IN ('processing','pending')",
    [uid]);
  const peerType = (t) => (t === 'found' ? 'lost' : 'found');
  for (const mine of myPosts) {
    const peers = await query(
      "SELECT id, title, location, created_at FROM post WHERE type = ? AND category = ? AND user_id <> ? " +
      "AND audit_status = 'approved' AND status IN ('processing','pending') ORDER BY created_at DESC LIMIT 5",
      [peerType(mine.type), mine.category, uid]);
    peers.forEach((l) => {
      const label = mine.type === 'found' ? '你的寻物' : '你的失物';
      const kind = mine.type === 'found' ? '失物' : '寻物';
      match.push(item('mt-' + l.id + '-' + mine.id, 'match', '匹配提醒',
        '发现与' + label + '《' + mine.title + '》同类别的' + kind + '《' + l.title + '》' + (l.location ? ' · ' + l.location : ''),
        l.created_at, mtRead));
    });
  }

  ok(res, { system, match, interact });
});

// 标记某类通知已读
router.put('/:type/read', requireAuth, async (req, res) => {
  const type = TYPES.indexOf(req.params.type) !== -1 ? req.params.type : 'system';
  await query(
    'INSERT INTO notif_read (user_id, type, read_at) VALUES (?, ?, NOW()) ON DUPLICATE KEY UPDATE read_at = NOW()',
    [req.user.uid, type]);
  ok(res, { ok: true });
});

module.exports = router;
