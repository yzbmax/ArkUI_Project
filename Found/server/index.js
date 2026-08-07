/**
 * 校园失物招领 App 后端入口
 * Express + MySQL(harmony)，监听 0.0.0.0:3000（模拟器/真机可访问）
 */
const express = require('express');
const cors = require('cors');
const path = require('path');
const { fail } = require('./utils');
const { optionalAuth } = require('./auth');

const app = express();
app.use(cors());
// limit 调大以接收 base64 图片数据
app.use(express.json({ limit: '20mb' }));
// 可选鉴权：列表/详情在已登录时返回个性化 liked/collected 等字段
app.use(optionalAuth);
app.use('/static', express.static(path.join(__dirname, 'static')));

app.get('/api/health', (req, res) => res.json({ code: 0, message: 'ok', data: { ok: true, time: new Date().toISOString() } }));

app.use('/api/auth', require('./routes/auth'));
app.use('/api/posts', require('./routes/posts'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/users', require('./routes/users'));
app.use('/api/claims', require('./routes/claims'));
app.use('/api/clues', require('./routes/clues'));
app.use('/api/messages', require('./routes/messages'));
app.use('/api/chats', require('./routes/chats'));
app.use('/api/credit', require('./routes/credit'));
app.use('/api/categories', require('./routes/categories'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/upload', require('./routes/upload'));

// 404 兜底
app.use((req, res) => fail(res, 404, 'Not Found', 404));

// 错误兜底（不泄漏堆栈）
app.use((err, req, res, next) => {
  console.error('[server error]', err);
  fail(res, 500, err.message, 500);
});

// 兜底：异步路由中未捕获的异常（如 DB 错误）不应把整个服务带崩
process.on('unhandledRejection', (reason) => {
  console.error('[unhandledRejection]', reason);
});

const PORT = Number(process.env.PORT || 3000);
app.listen(PORT, '0.0.0.0', () => {
  console.log(`found-server listening on http://0.0.0.0:${PORT}`);
});
