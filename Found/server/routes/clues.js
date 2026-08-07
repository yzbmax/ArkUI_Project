/**
 * 线索路由（前端本次不接线，供以后扩展）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, uuid, relativeTime } = require('../utils');
const { requireAuth } = require('../auth');

// 我的线索
router.get('/', requireAuth, async (req, res) => {
  const rows = await query(
    'SELECT c.*, p.title AS post_title FROM clue c JOIN post p ON c.post_id=p.id WHERE c.provider_id = ? ORDER BY c.created_at DESC',
    [req.user.uid]
  );
  const list = rows.map((r) => ({
    id: r.id, postTitle: r.post_title, desc: r.content,
    status: r.is_helpful === null || r.is_helpful === undefined ? 'pending' : (r.is_helpful === 1 ? 'valid' : 'invalid'),
    time: relativeTime(r.created_at)
  }));
  ok(res, { list });
});

// 我收到的线索（我发布的寻物动态上的线索，供失主处理）
router.get('/received', requireAuth, async (req, res) => {
  const rows = await query(
    `SELECT c.*, p.title AS post_title, p.user_id AS owner_id, u.nickname AS provider
     FROM clue c JOIN post p ON c.post_id=p.id JOIN \`user\` u ON c.provider_id=u.id
     WHERE p.user_id = ? ORDER BY c.created_at DESC`,
    [req.user.uid]
  );
  const list = rows.map((r) => ({
    id: r.id, postId: r.post_id, postTitle: r.post_title, provider: r.provider,
    content: r.content, helpful: !!r.is_helpful, time: relativeTime(r.created_at)
  }));
  ok(res, { list });
});

// 标记线索有效/无效（仅失主本人）
router.put('/:id/helpful', requireAuth, async (req, res) => {
  const { helpful } = req.body || {};
  const rows = await query('SELECT c.id, p.user_id AS owner_id FROM clue c JOIN post p ON c.post_id=p.id WHERE c.id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '线索不存在', 404);
  if (rows[0].owner_id !== req.user.uid) return fail(res, 403, '无权操作', 403);
  await query('UPDATE clue SET is_helpful = ? WHERE id = ?', [helpful ? 1 : 0, req.params.id]);
  ok(res, { ok: true }, helpful ? '已标记有效' : '已标记无效');
});

// 提交线索
router.post('/', requireAuth, async (req, res) => {
  const { postId, content } = req.body || {};
  if (!postId || !content) return fail(res, 1, '动态与线索内容必填');
  const post = await query('SELECT id FROM post WHERE id = ?', [postId]);
  if (post.length === 0) return fail(res, 404, '动态不存在', 404);
  await query('INSERT INTO clue (id, post_id, provider_id, content) VALUES (?,?,?,?)',
    [uuid(), postId, req.user.uid, content]);
  ok(res, { ok: true }, '线索已提交');
});

module.exports = router;
