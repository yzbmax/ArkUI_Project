/**
 * 图片上传（base64 JSON）：保存到 static/images/uploads/，返回相对 URL
 * POST /api/upload  body: { images: string[] }（每项为 base64 字符串）
 */
const express = require('express');
const fs = require('fs');
const path = require('path');
const router = express.Router();
const { ok, fail, uuid } = require('../utils');
const { requireAuth } = require('../auth');

router.post('/', requireAuth, async (req, res) => {
  const { images } = req.body || {};
  if (!Array.isArray(images) || images.length === 0) {
    return fail(res, 1, '没有图片数据');
  }
  const uploadDir = path.join(__dirname, '..', 'static', 'images', 'uploads');
  fs.mkdirSync(uploadDir, { recursive: true });
  const urls = [];
  for (const img of images) {
    if (typeof img !== 'string' || img.length < 100) {
      continue; // 过滤无效数据
    }
    const name = uuid() + '.jpg';
    try {
      fs.writeFileSync(path.join(uploadDir, name), Buffer.from(img, 'base64'));
      urls.push('/static/images/uploads/' + name);
    } catch (e) {
      // 单张失败跳过
    }
  }
  ok(res, { urls }, '上传成功');
});

module.exports = router;
