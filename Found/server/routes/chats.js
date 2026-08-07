/**
 * 会话路由（按对话对象聚合私信，前端本次不接线）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, uuid, relativeTime } = require('../utils');
const { requireAuth } = require('../auth');

// 会话列表（含最近消息与未读数）
router.get('/', requireAuth, async (req, res) => {
  const uid = req.user.uid;
  const rows = await query(
    `SELECT m.*, u.id AS peer_id, u.nickname AS peer FROM message m
     JOIN \`user\` u ON u.id = (CASE WHEN m.from_user_id = ? THEN m.to_user_id ELSE m.from_user_id END)
     WHERE m.from_user_id = ? OR m.to_user_id = ?
     ORDER BY m.created_at ASC`,
    [uid, uid, uid]
  );
  const sessions = new Map();
  for (const r of rows) {
    const key = r.peer_id;
    if (!sessions.has(key)) {
      sessions.set(key, { id: 's' + key, peerId: r.peer_id, name: r.peer, lastMsg: '', time: '', unread: 0, messages: [] });
    }
    const s = sessions.get(key);
    s.messages.push({ me: r.from_user_id === uid, content: r.content, time: relativeTime(r.created_at) });
    s.lastMsg = r.content;
    s.time = relativeTime(r.created_at);
    if (r.to_user_id === uid && r.is_read === 0) s.unread += 1;
  }
  ok(res, { list: [...sessions.values()] });
});

// 发送消息
router.post('/:peerId', requireAuth, async (req, res) => {
  const { content } = req.body || {};
  if (!content || !String(content).trim()) return fail(res, 1, '消息不能为空');
  const id = uuid();
  await query('INSERT INTO message (id, from_user_id, to_user_id, content) VALUES (?,?,?,?)',
    [id, req.user.uid, req.params.peerId, String(content).trim()]);
  ok(res, { id, me: true, content: String(content).trim(), time: relativeTime(new Date()) }, '已发送');
});

module.exports = router;
