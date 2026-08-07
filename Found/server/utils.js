/**
 * 通用工具：响应信封 / uuid / 相对时间 / 分页 / JSON 解析
 */
const crypto = require('crypto');

/** 成功响应：{ code:0, message, data } */
function ok(res, data, message = 'ok') {
  res.json({ code: 0, message, data: data === undefined ? null : data });
}

/** 失败响应：{ code, message, data:null }，同时保留 HTTP 状态码 */
function fail(res, code, message, httpStatus = 400) {
  res.status(httpStatus).json({ code, message, data: null });
}

function uuid() {
  return crypto.randomUUID();
}

/** DATETIME/时间戳 → 「刚刚 / N分钟前 / N小时前 / N天前 / yyyy-MM-dd」 */
function relativeTime(d) {
  if (!d) return '';
  const t = new Date(d).getTime();
  if (isNaN(t)) return '';
  const diff = Date.now() - t;
  if (diff < 60 * 1000) return '刚刚';
  if (diff < 3600 * 1000) return Math.floor(diff / 60000) + '分钟前';
  if (diff < 24 * 3600 * 1000) return Math.floor(diff / 3600000) + '小时前';
  const day = Math.floor(diff / 86400000);
  if (day < 7) return day + '天前';
  const dt = new Date(d);
  const y = dt.getFullYear();
  const m = String(dt.getMonth() + 1).padStart(2, '0');
  const dd = String(dt.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

/** JSON 列安全解析 */
function parseJson(s, fallback) {
  if (!s) return fallback;
  if (Array.isArray(s)) return s;
  try {
    const v = JSON.parse(s);
    return v === null || v === undefined ? fallback : v;
  } catch (e) {
    return fallback;
  }
}

/** 分页参数归一化：page≥1，size 1~100 */
function pageParams(q) {
  const page = Math.max(1, parseInt(q.page, 10) || 1);
  const size = Math.min(100, Math.max(1, parseInt(q.size, 10) || 20));
  return { page, size, offset: (page - 1) * size };
}

/** 剔除用户敏感字段（password_hash 等） */
function sanitizeUser(u) {
  if (!u) return u;
  const clone = { ...u };
  delete clone.password_hash;
  return clone;
}

/** 信用等级（对齐 PRD 5.6.5） */
function creditLevel(score) {
  if (score >= 500) return 5;
  if (score >= 301) return 4;
  if (score >= 151) return 3;
  if (score >= 51) return 2;
  return 1;
}

module.exports = { ok, fail, uuid, relativeTime, parseJson, pageParams, sanitizeUser, creditLevel };
