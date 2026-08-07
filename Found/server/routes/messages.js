/**
 * 消息路由（私信，前端本次不接线，供以后扩展）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, relativeTime } = require('../utils');
const { requireAuth } = require('../auth');

// 我的消息（与我有关系的私信，按时间倒序）
router.get('/', requireAuth, async (req, res) => {
  const rows = await query(
    `SELECT m.*, u.nickname AS peer FROM message m
     JOIN \`user\` u ON u.id = (CASE WHEN m.from_user_id = ? THEN m.to_user_id ELSE m.from_user_id END)
     WHERE m.from_user_id = ? OR m.to_user_id = ?
     ORDER BY m.created_at DESC LIMIT 100`,
    [req.user.uid, req.user.uid, req.user.uid]
  );
  const list = rows.map((r) => ({
    id: r.id,
    type: 'chat',
    title: r.peer,
    content: r.content,
    time: relativeTime(r.created_at),
    unread: r.to_user_id === req.user.uid && r.is_read === 0
  }));
  ok(res, { list });
});

// 标记已读
router.put('/:id/read', requireAuth, async (req, res) => {
  await query('UPDATE message SET is_read = 1 WHERE id = ? AND to_user_id = ?', [req.params.id, req.user.uid]);
  ok(res, { ok: true });
});

module.exports = router;
