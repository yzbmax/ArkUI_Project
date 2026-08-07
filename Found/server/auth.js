/**
 * 鉴权：JWT 签发/校验 + 中间件
 */
const jwt = require('jsonwebtoken');
const { fail } = require('./utils');

const SECRET = process.env.JWT_SECRET || 'found-dev-secret-2026';
const EXPIRES = '7d';

function signToken(user) {
  return jwt.sign({ uid: user.id, role: user.role }, SECRET, { expiresIn: EXPIRES });
}

function verifyToken(token) {
  return jwt.verify(token, SECRET);
}

/** 需登录（把解出的 {uid, role} 挂到 req.user） */
function requireAuth(req, res, next) {
  const h = req.headers.authorization || '';
  const t = h.startsWith('Bearer ') ? h.slice(7) : '';
  if (!t) return fail(res, 401, '未登录，请先登录', 401);
  try {
    req.user = verifyToken(t);
    next();
  } catch (e) {
    return fail(res, 401, '登录已过期，请重新登录', 401);
  }
}

/** 需管理员角色 */
function requireAdmin(req, res, next) {
  requireAuth(req, res, () => {
    if (req.user.role !== 'admin') return fail(res, 403, '无权限', 403);
    next();
  });
}

/**
 * 可选鉴权：有有效 token 则解析挂到 req.user，无/无效 token 不拦截。
 * 用于公开接口（列表/详情）在已登录时返回个性化字段（liked/collected 等）。
 */
function optionalAuth(req, res, next) {
  const h = req.headers.authorization || '';
  const t = h.startsWith('Bearer ') ? h.slice(7) : '';
  if (t) {
    try { req.user = verifyToken(t); } catch (e) { /* 忽略无效 token，按匿名处理 */ }
  }
  next();
}

module.exports = { signToken, verifyToken, requireAuth, requireAdmin, optionalAuth };
