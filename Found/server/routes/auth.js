/**
 * 认证路由：注册 / 登录 / 登出 / 找回密码 / 当前用户
 */
const express = require('express');
const bcrypt = require('bcryptjs');
const router = express.Router();
const { query } = require('../db');
const { ok, fail, uuid, creditLevel } = require('../utils');
const { signToken, requireAuth } = require('../auth');

/** 数据库 user 行 → 前端 UserProfile（含计算信用等级） */
function userToProfile(row) {
  return {
    id: row.id,
    phone: row.phone,
    nickname: row.nickname,
    avatar: row.avatar || '',
    role: row.role,
    campus: row.campus,
    creditScore: row.credit_score,
    creditLevel: creditLevel(row.credit_score),
    realName: row.real_name,
    department: row.department,
    studentId: row.student_id
  };
}

// 注册
router.post('/register', async (req, res) => {
  const { phone, password, nickname, role, studentId, realName, department, campus } = req.body || {};
  if (!phone || !password || !nickname) return fail(res, 1, '手机号、密码、昵称不能为空');
  if (!/^1\d{10}$/.test(String(phone))) return fail(res, 1, '手机号格式不正确');
  if (password.length < 6 || password.length > 20) return fail(res, 1, '密码长度需 6~20 位');
  const roleList = ['student', 'teacher', 'staff'];
  if (roleList.indexOf(role) === -1) return fail(res, 1, '角色不正确');
  if (!studentId) return fail(res, 1, '学号/工号不能为空');

  const exist = await query('SELECT id FROM `user` WHERE phone = ? OR nickname = ?', [phone, nickname]);
  if (exist.length > 0) return fail(res, 1, '手机号或昵称已被注册');

  const id = uuid();
  const hash = bcrypt.hashSync(password, 10);
  await query(
    'INSERT INTO `user` (id, phone, password_hash, nickname, real_name, student_id, role, department, campus, credit_score, status) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
    [id, phone, hash, nickname, realName || '', studentId, role, department || '', campus || '中心校区', 20, 'normal']
  );
  // 注册奖励 +20
  await query(
    'INSERT INTO credit_log (id, user_id, `change`, event_type, description, balance) VALUES (?,?,?,?,?,?)',
    [uuid(), id, 20, 'register', '注册奖励', 20]
  );

  const row = await query('SELECT * FROM `user` WHERE id = ?', [id]);
  const token = signToken(row[0]);
  ok(res, { token, user: userToProfile(row[0]) }, '注册成功');
});

// 登录
router.post('/login', async (req, res) => {
  const { phone, password } = req.body || {};
  if (!phone || !password) return fail(res, 1, '请输入手机号和密码');
  const rows = await query('SELECT * FROM `user` WHERE phone = ?', [phone]);
  if (rows.length === 0) return fail(res, 1, '账号不存在');
  const user = rows[0];
  if (user.status === 'frozen') return fail(res, 1, '账号已冻结，请联系管理员');
  if (user.status === 'deleted') return fail(res, 1, '账号不存在');
  if (!bcrypt.compareSync(password, user.password_hash)) return fail(res, 1, '密码错误');

  await query('UPDATE `user` SET last_login = NOW() WHERE id = ?', [user.id]);
  const token = signToken(user);
  ok(res, { token, user: userToProfile(user) }, '登录成功');
});

// 登出（无状态 JWT，服务端幂等返回）
router.post('/logout', requireAuth, (req, res) => {
  ok(res, { ok: true }, '已退出');
});

// 找回密码
router.post('/forgot-password', async (req, res) => {
  const { phone, newPassword } = req.body || {};
  if (!phone || !newPassword) return fail(res, 1, '手机号和新密码不能为空');
  if (newPassword.length < 6 || newPassword.length > 20) return fail(res, 1, '密码长度需 6~20 位');
  const rows = await query('SELECT id FROM `user` WHERE phone = ?', [phone]);
  if (rows.length === 0) return fail(res, 1, '账号不存在');
  await query('UPDATE `user` SET password_hash = ? WHERE id = ?', [bcrypt.hashSync(newPassword, 10), rows[0].id]);
  ok(res, { ok: true }, '密码已重置');
});

// 当前用户（Splash 用 token 校验）
router.get('/me', requireAuth, async (req, res) => {
  const rows = await query('SELECT * FROM `user` WHERE id = ?', [req.user.uid]);
  if (rows.length === 0) return fail(res, 401, '用户不存在', 401);
  ok(res, userToProfile(rows[0]));
});

module.exports = router;
