/**
 * 信用积分路由（前端本次不接线，供以后扩展）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, relativeTime, creditLevel } = require('../utils');
const { requireAuth } = require('../auth');

const EVENT_NAMES = {
  register: '注册奖励', post: '发布动态', return: '成功归还', find: '成功找回',
  clue: '有效线索', thank: '感谢动态', reported: '被举报', fraud: '冒领', timeout: '超时扣分'
};

// 我的积分明细 + 余额 + 等级
router.get('/logs', requireAuth, async (req, res) => {
  const rows = await query('SELECT * FROM credit_log WHERE user_id = ? ORDER BY created_at DESC LIMIT 100', [req.user.uid]);
  const me = await query('SELECT credit_score FROM `user` WHERE id = ?', [req.user.uid]);
  const balance = (me[0] && me[0].credit_score) || 0;
  const logs = rows.map((r) => ({
    id: r.id,
    event: r.description || (EVENT_NAMES[r.event_type] || r.event_type),
    delta: r.change,
    balance: r.balance,
    time: relativeTime(r.created_at)
  }));
  ok(res, { balance, level: creditLevel(balance), logs });
});

module.exports = router;
