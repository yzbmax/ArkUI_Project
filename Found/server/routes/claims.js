/**
 * 认领路由（前端本次不接线，供以后扩展）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, uuid, relativeTime } = require('../utils');
const { requireAuth } = require('../auth');

// 我的认领记录
router.get('/', requireAuth, async (req, res) => {
  const rows = await query(
    'SELECT c.*, p.title AS post_title, u.nickname AS applicant FROM claim c JOIN post p ON c.post_id=p.id JOIN `user` u ON c.claimant_id=u.id WHERE c.claimant_id = ? ORDER BY c.created_at DESC',
    [req.user.uid]
  );
  const list = rows.map((r) => ({ id: r.id, postTitle: r.post_title, applicant: r.applicant, desc: r.description, status: r.status, time: relativeTime(r.created_at) }));
  ok(res, { list });
});

// 我收到的认领（我发布的动态上的认领申请，供发布者审核）
router.get('/received', requireAuth, async (req, res) => {
  const rows = await query(
    `SELECT c.*, p.title AS post_title, p.user_id AS owner_id, u.nickname AS claimant
     FROM claim c JOIN post p ON c.post_id=p.id JOIN \`user\` u ON c.claimant_id=u.id
     WHERE p.user_id = ? ORDER BY c.created_at DESC`,
    [req.user.uid]
  );
  const list = rows.map((r) => ({
    id: r.id, postId: r.post_id, postTitle: r.post_title, claimant: r.claimant,
    desc: r.description, verifyAnswer: r.verify_answer, status: r.status, time: relativeTime(r.created_at)
  }));
  ok(res, { list });
});

// 审核认领（通过/驳回，仅发布者本人）
router.put('/:id/status', requireAuth, async (req, res) => {
  const { status } = req.body || {};
  if (['approved', 'rejected', 'cancelled'].indexOf(status) === -1) {
    return fail(res, 1, '状态不正确');
  }
  const rows = await query('SELECT c.id, c.post_id, p.user_id AS owner_id FROM claim c JOIN post p ON c.post_id=p.id WHERE c.id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '认领不存在', 404);
  if (rows[0].owner_id !== req.user.uid) return fail(res, 403, '无权操作', 403);
  const claim = rows[0];
  await query('UPDATE claim SET status = ?, resolved_at = NOW() WHERE id = ?', [status, req.params.id]);
  // 认领通过：动态标记为已归还（从公开列表消失），并驳回同一动态上其他待审核认领
  if (status === 'approved') {
    await query("UPDATE post SET status = 'resolved' WHERE id = ?", [claim.post_id]);
    await query("UPDATE claim SET status = 'rejected' WHERE post_id = ? AND id <> ? AND status = 'pending'", [claim.post_id, req.params.id]);
  }
  ok(res, { ok: true }, status === 'approved' ? '已通过，动态已标记为已归还' : '已驳回');
});

// 提交认领
router.post('/', requireAuth, async (req, res) => {
  const { postId, description, verifyAnswer } = req.body || {};
  if (!postId || !description) return fail(res, 1, '动态与认领说明必填');
  const post = await query('SELECT id FROM post WHERE id = ?', [postId]);
  if (post.length === 0) return fail(res, 404, '动态不存在', 404);
  await query('INSERT INTO claim (id, post_id, claimant_id, description, verify_answer) VALUES (?,?,?,?,?)',
    [uuid(), postId, req.user.uid, description, verifyAnswer || '']);
  ok(res, { ok: true }, '认领申请已提交');
});

module.exports = router;
