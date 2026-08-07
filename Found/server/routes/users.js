/**
 * 用户路由：我的动态 / 我的资料 / 公开主页
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, pageParams } = require('../utils');
const { requireAuth } = require('../auth');
const { rowsToPosts } = require('../postMapper');

// 我的发布（按 status / type 过滤，供 MyPosts 分组 + 个人页失物寻物 Tab）
router.get('/me/posts', requireAuth, async (req, res) => {
  const { status, type } = req.query;
  const { page, size, offset } = pageParams(req.query);
  const where = ['user_id = ?'];
  const params = [req.user.uid];
  if (status) {
    if (status === 'pending') {
      // 待审核 + 被驳回（audit_status pending 或 rejected）
      where.push("(audit_status = 'pending' OR audit_status = 'rejected')");
    } else {
      where.push('status = ?');
      params.push(status);
    }
  }
  if (type && (type === 'lost' || type === 'found')) {
    where.push('type = ?');
    params.push(type);
  }
  const whereSql = 'WHERE ' + where.join(' AND ');
  const cnt = await query(`SELECT COUNT(*) AS c FROM post ${whereSql}`, params);
  const rows = await query(`SELECT * FROM post ${whereSql} ORDER BY created_at DESC LIMIT ? OFFSET ?`, [...params, size, offset]);
  const list = await rowsToPosts(rows, req.user.uid);
  ok(res, { list, total: cnt[0].c, page, size, hasMore: offset + rows.length < cnt[0].c });
});

// 更新我的资料
router.put('/me', requireAuth, async (req, res) => {
  const { nickname, campus, department, avatar } = req.body || {};
  if (nickname !== undefined && !String(nickname).trim()) return fail(res, 1, '昵称不能为空');
  const sets = [];
  const params = [];
  if (nickname !== undefined) { sets.push('nickname = ?'); params.push(String(nickname).trim()); }
  if (campus !== undefined) { sets.push('campus = ?'); params.push(campus); }
  if (department !== undefined) { sets.push('department = ?'); params.push(department); }
  if (avatar !== undefined) { sets.push('avatar = ?'); params.push(String(avatar).trim()); }
  if (sets.length === 0) return fail(res, 1, '没有可更新的字段');
  await query(`UPDATE \`user\` SET ${sets.join(', ')} WHERE id = ?`, [...params, req.user.uid]);
  const rows = await query('SELECT * FROM `user` WHERE id = ?', [req.user.uid]);
  ok(res, {
    id: rows[0].id, nickname: rows[0].nickname, avatar: rows[0].avatar || '', role: rows[0].role,
    campus: rows[0].campus, creditScore: rows[0].credit_score, department: rows[0].department
  });
});

// 我的收藏（P19 收藏列表）
router.get('/me/collects', requireAuth, async (req, res) => {
  const rows = await query(
    'SELECT p.* FROM collect c JOIN post p ON c.post_id = p.id WHERE c.user_id = ? ORDER BY c.created_at DESC',
    [req.user.uid]);
  const list = await rowsToPosts(rows, req.user.uid);
  ok(res, { list });
});

// 公开主页
router.get('/:id', async (req, res) => {
  const rows = await query('SELECT id, nickname, avatar, role, department, campus, credit_score, grade FROM `user` WHERE id = ?', [req.params.id]);
  if (rows.length === 0) return fail(res, 404, '用户不存在', 404);
  const u = rows[0];
  ok(res, { id: u.id, nickname: u.nickname, avatar: u.avatar || '', role: u.role, department: u.department, campus: u.campus, creditScore: u.credit_score });
});

// 该用户发布的动态
router.get('/:id/posts', async (req, res) => {
  const rows = await query("SELECT * FROM post WHERE user_id = ? AND audit_status = 'approved' ORDER BY created_at DESC", [req.params.id]);
  const list = await rowsToPosts(rows, req.user ? req.user.uid : null);
  ok(res, { list });
});

module.exports = router;
