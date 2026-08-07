/**
 * 分类路由（对齐前端 CATEGORIES）
 */
const express = require('express');
const router = express.Router();
const { query } = require('../db');
const { ok, parseJson } = require('../utils');

router.get('/', async (req, res) => {
  const rows = await query('SELECT cat_key, name, icon, sub FROM category ORDER BY sort ASC');
  const list = rows.map((r) => ({ key: r.cat_key, name: r.name, icon: r.icon, sub: parseJson(r.sub, []) }));
  ok(res, { list });
});

module.exports = router;
