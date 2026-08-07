/**
 * 管理端路由：审核 / 举报 / 用户管理（全部 requireAdmin）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, uuid, pageParams, sanitizeUser } = require('../utils');
const { requireAdmin } = require('../auth');
const { rowsToPosts } = require('../postMapper');

// 待审核列表
router.get('/audits', requireAdmin, async (req, res) => {
  const { page, size, offset } = pageParams(req.query);
  const cnt = await query("SELECT COUNT(*) AS c FROM post WHERE audit_status = 'pending'");
  const rows = await query("SELECT * FROM post WHERE audit_status = 'pending' ORDER BY created_at ASC LIMIT ? OFFSET ?", [size, offset]);
  const list = await rowsToPosts(rows, req.user.uid);
  ok(res, { list, total: cnt[0].c, page, size, hasMore: offset + rows.length < cnt[0].c });
});

// 审核通过
router.post('/audits/:id/approve', requireAdmin, async (req, res) => {
  const rows = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  await query("UPDATE post SET audit_status = 'approved', status = 'processing' WHERE id = ?", [req.params.id]);
  const updated = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  const list = await rowsToPosts(updated, req.user.uid);
  ok(res, list[0], '审核通过');
});

// 审核驳回（填理由）
router.post('/audits/:id/reject', requireAdmin, async (req, res) => {
  const { reason } = req.body || {};
  if (!reason || !String(reason).trim()) return fail(res, 1, '驳回必须填写理由');
  const rows = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '动态不存在', 404);
  await query("UPDATE post SET audit_status = 'rejected', audit_remark = ? WHERE id = ?", [String(reason).trim(), req.params.id]);
  const updated = await query('SELECT * FROM post WHERE id = ?', [req.params.id]);
  const list = await rowsToPosts(updated, req.user.uid);
  ok(res, list[0], '已驳回');
});

// 举报列表
router.get('/reports', requireAdmin, async (req, res) => {
  const { status } = req.query;
  const { page, size, offset } = pageParams(req.query);
  const where = status ? 'WHERE r.status = ?' : '';
  const params = status ? [status] : [];
  const cnt = await query(`SELECT COUNT(*) AS c FROM report r ${where}`, params);
  const rows = await query(
    `SELECT r.*, u.nickname AS reporter_name FROM report r JOIN \`user\` u ON r.reporter_id=u.id ${where} ORDER BY r.created_at DESC LIMIT ? OFFSET ?`,
    [...params, size, offset]
  );
  const list = rows.map((r) => ({
    id: r.id,
    target: r.target_type === 'user' ? (r.target_id || '') : r.target_id,
    targetType: r.target_type,
    reason: r.reason,
    description: r.description,
    status: r.status,
    reporter: r.reporter_name,
    time: require('../utils').relativeTime(r.created_at),
    result: r.result || ''
  }));
  ok(res, { list, total: cnt[0].c, page, size, hasMore: offset + rows.length < cnt[0].c });
});

// 处理举报
router.post('/reports/:id/handle', requireAdmin, async (req, res) => {
  const { status, result } = req.body || {};
  const allowed = ['dismissed', 'warned', 'deleted', 'frozen'];
  if (allowed.indexOf(status) === -1) return fail(res, 1, '处理状态不正确');
  const rows = await query('SELECT id FROM report WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '举报不存在', 404);
  await query('UPDATE report SET status = ?, result = ?, handler_id = ?, handled_at = NOW() WHERE id = ?',
    [status, result || '', req.user.uid, req.params.id]);
  ok(res, { ok: true }, '处理完成');
});

// 用户列表
router.get('/users', requireAdmin, async (req, res) => {
  const { role, keyword } = req.query;
  const { page, size, offset } = pageParams(req.query);
  const where = [];
  const params = [];
  if (role) { where.push('role = ?'); params.push(role); }
  if (keyword) { where.push('(nickname LIKE ? OR phone LIKE ? OR student_id LIKE ?)'); const like = '%' + keyword + '%'; params.push(like, like, like); }
  const whereSql = where.length ? 'WHERE ' + where.join(' AND ') : '';
  const cnt = await query(`SELECT COUNT(*) AS c FROM \`user\` ${whereSql}`, params);
  const rows = await query(`SELECT * FROM \`user\` ${whereSql} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...params, size, offset]);
  const list = rows.map((u) => ({
    id: u.id, phone: u.phone, nickname: u.nickname, role: u.role, department: u.department,
    campus: u.campus, creditScore: u.credit_score, status: u.status, createdAt: u.created_at
  }));
  ok(res, { list, total: cnt[0].c, page, size, hasMore: offset + rows.length < cnt[0].c });
});

module.exports = router;
