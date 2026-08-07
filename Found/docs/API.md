# 校园失物招领 App — 后端 API 接口文档

| 项目 | 内容 |
|------|------|
| 文档版本 | v1.0 |
| 服务端 | Node.js + Express + mysql2（`server/` 目录） |
| 数据库 | MySQL `harmony` 库（11 张表） |
| 默认地址 | `http://127.0.0.1:3000`（监听 `0.0.0.0`） |
| 关联文档 | 《docs/PRD.md》（数据模型 7.2）、《docs/todo.md》（阶段 B） |

> 本接口文档描述 `server/` 当前实现的真实接口行为，前端 `entry/src/main/ets/shared/api/ApiRepo.ets` 为其对应实现。

---

## 一、基础约定

### 1.1 Base URL 与端口

```
http://<host>:3000
```

- 本机联调：`http://127.0.0.1:3000`
- Android/Harmony 模拟器访问宿主机：使用宿主机局域网 IP（或模拟器专用映射地址）
- 真机：与 PC 同一网段，使用 PC 局域网 IP，并放行 3000 端口

### 1.2 响应信封

所有接口返回统一 JSON 信封：

```json
{ "code": 0, "message": "ok", "data": { ... } }
```

| 字段 | 说明 |
|------|------|
| `code` | 业务码。`0` = 成功；非 `0` = 业务错误（1 参数错误、401 未登录、403 无权限、404 不存在、500 服务异常） |
| `message` | 人类可读提示（错误时前端可直接 Toast 展示，如「密码错误」「账号不存在」「账号已冻结，请联系管理员」） |
| `data` | 业务数据，失败时为 `null` |

HTTP 状态码同时保留语义：成功 `200`；错误 `400 / 401 / 403 / 404 / 500`。前端 `HttpClient` 在非 200 时解析 `message` 字段抛出 `ApiError`。

### 1.3 鉴权

- 登录/注册成功返回 `token`（JWT，有效期 7 天）。
- 受保护接口需在请求头携带：`Authorization: Bearer <token>`
- 前端：`AppStore` 登录后写入 `AppStorage['token']`，`HttpClient` 自动注入。

### 1.4 分页

列表接口统一支持查询参数：

| 参数 | 说明 |
|------|------|
| `page` | 页码，从 1 开始，默认 1 |
| `size` | 每页条数，1~100，默认 20 |

响应 `data` 统一为：

```json
{ "list": [...], "total": 58, "page": 1, "size": 8, "hasMore": true }
```

### 1.5 时间字段

- 数据库存 `DATETIME`；接口返回 `time` 为**相对时间字符串**（`刚刚 / N分钟前 / N小时前 / N天前 / yyyy-MM-dd`），前端直接展示。
- 图片字段为**相对路径**（如 `/static/images/p1.png`），前端需拼接 Base URL（`ApiRepo` 已自动处理）。

---

## 二、数据类型定义

### 2.1 用户 User

```json
{
  "id": "30057cfc-...",
  "phone": "13800000002",
  "nickname": "小南",
  "avatar": "",
  "role": "student",
  "campus": "中心校区",
  "creditScore": 132,
  "creditLevel": 2,
  "realName": "张南",
  "department": "计算机学院",
  "studentId": "20240101"
}
```

| 字段 | 说明 |
|------|------|
| `role` | `student` 学生 / `teacher` 教师 / `staff` 教职工 / `admin` 管理员 |
| `creditLevel` | 信用等级 1~5（后端按积分计算，对齐 PRD 5.6.5） |
| 敏感字段 | `realName` / `studentId` 仅本人可见，列表接口不返回 |

### 2.2 动态 Post

```json
{
  "id": "p2",
  "userId": "30057cfc-...",
  "type": "found",
  "title": "丢失钥匙钱包",
  "desc": "大概在教学楼三层自习区丢失的……",
  "category": "key",
  "categoryName": "钥匙钱包",
  "location": "教学楼",
  "time": "6小时前",
  "images": ["/static/images/p2.png"],
  "contact": "App 内私信",
  "verifyQuestion": "",
  "anonymous": false,
  "urgent": false,
  "reward": "",
  "status": "resolved",
  "rejectReason": "",
  "author": "小南",
  "authorAvatar": "",
  "creditLevel": 2,
  "likes": 14,
  "comments": 1,
  "liked": false,
  "collected": false
}
```

| 字段 | 说明 |
|------|------|
| `type` | `lost` 失物（捡到）/ `found` 寻物（丢失） |
| `category` / `categoryName` | 一级分类 key 与中文名（对齐前端 CATEGORIES） |
| `status` | `pending` 待审核 / `processing` 进行中 / `resolved` 已完结 / `closed` 已关闭 |
| `rejectReason` | 审核驳回理由（未驳回为空） |
| `liked` / `collected` | 当前登录用户是否已点赞/收藏；未登录恒为 `false` |
| `commentList` | 评论数组，**仅详情接口返回** |

> `status=pending` 与审核状态联动：待审核动态不会出现在公开列表，仅管理端审核列表与「我的发布-待审核」可见。

### 2.3 评论 Comment

```json
{
  "id": "c-xxx",
  "author": "小南",
  "avatar": "",
  "content": "我在现场看到过……",
  "time": "1小时前",
  "replyTo": "",
  "replies": [
    { "id": "c-yyy", "author": "阿诚", "avatar": "", "content": "好的，谢谢", "time": "50分钟前", "replyTo": "小南", "replies": [] }
  ]
}
```

`replies` 支持一层楼中楼（回复的回复不再嵌套）。

### 2.4 举报 Report（管理端）

```json
{
  "id": "r-xxx",
  "target": "p3",
  "targetType": "post",
  "reason": "fake",
  "description": "垃圾广告",
  "status": "pending",
  "reporter": "李诚",
  "time": "1小时前",
  "result": ""
}
```

| 字段 | 说明 |
|------|------|
| `reason` | `fake` 虚假信息 / `fraud` 冒领 / `harass` 骚扰 / `inappropriate` 不良内容 / `other` 其他 |
| `status` | `pending` 待处理 / `dismissed` 已驳回 / `warned` 已警告 / `deleted` 已删除 / `frozen` 已冻结 |

---

## 三、接口清单

### 3.1 认证 Auth — `/api/auth`

#### POST `/api/auth/register` 注册

请求体：

```json
{
  "phone": "13812345678",
  "password": "abc123",
  "nickname": "新同学",
  "role": "student",
  "studentId": "20240101",
  "realName": "张三",
  "department": "计算机学院",
  "campus": "中心校区"
}
```

| 字段 | 必填 | 校验 |
|------|:----:|------|
| `phone` | ✅ | 11 位手机号 |
| `password` | ✅ | 6~20 位 |
| `nickname` | ✅ | 全平台唯一 |
| `role` | ✅ | student / teacher / staff |
| `studentId` | ✅ | 学号/工号 |

响应 `data`：`{ "token": "eyJhbGci...", "user": { User } }`
- 注册即送 20 积分（写入 credit_log）；重复手机号/昵称返回「手机号或昵称已被注册」。

#### POST `/api/auth/login` 登录

请求体：`{ "phone": "13812345678", "password": "abc123" }`

响应 `data`：`{ "token": "...", "user": { User } }`

错误提示（前端直接展示 `message`）：
- `账号不存在`
- `密码错误`
- `账号已冻结，请联系管理员`（status=frozen）

#### POST `/api/auth/logout` 登出（需登录）

响应 `data`：`{ "ok": true }`（无状态 JWT，登出由前端清除 token 完成）

#### POST `/api/auth/forgot-password` 找回密码

请求体：`{ "phone": "13812345678", "newPassword": "newpass123" }`

响应 `data`：`{ "ok": true }`

#### GET `/api/auth/me` 当前用户（需登录）

响应 `data`：`{ User }`（前端 Splash 用此接口校验 token 有效性；失效返回 401「登录已过期，请重新登录」）

---

### 3.2 动态 Post — `/api/posts`

#### GET `/api/posts` 动态列表（分页 + 组合筛选）

查询参数（全部可选）：

| 参数 | 说明 |
|------|------|
| `type` | `lost` / `found` |
| `category` | 一级分类 key（如 `card`） |
| `keyword` | 关键词，支持**空格分词多词 AND**，匹配标题/描述/地点 |
| `urgent` | `1` 仅加急 |
| `status` | 按状态过滤 |
| `includePending` | `1` 包含待审核（默认不含） |
| `sort` | `urgent` 加急优先；缺省按发布时间倒序 |
| `page` / `size` | 分页 |

示例：
```
GET /api/posts?type=lost&category=card&page=1&size=8
GET /api/posts?keyword=图书馆%20耳机      # 同时命中「图书馆」和「耳机」
GET /api/posts?sort=urgent&page=1&size=20
```

响应 `data`：`{ "list": [Post], "total", "page", "size", "hasMore" }`
- 公开列表默认**排除** `audit_status=pending`（待审核）的动态。

#### GET `/api/posts/:id` 动态详情

响应 `data`：`Post`（含 `commentList`）。访问会自增 `view_count`。

#### POST `/api/posts` 发布动态（需登录，进审核）

请求体：

```json
{
  "type": "lost",
  "title": "捡到校园卡",
  "desc": "在图书馆捡到一张校园卡……",
  "category": "card",
  "categoryName": "证件卡类",
  "location": "图书馆",
  "contact": "App 内私信",
  "verifyQuestion": "卡套颜色是什么",
  "anonymous": false,
  "urgent": false,
  "reward": "奶茶一杯",
  "images": []
}
```

| 字段 | 必填 | 说明 |
|------|:----:|------|
| `type` / `title` / `desc` / `category` | ✅ | 类型/名称/描述/一级分类 |
| `categoryName` | 建议 | 前端可传，缺省后端存空串 |
| 其余 | 否 | 有默认值 |

响应 `data`：`Post`（`status=pending`，`audit_status=pending`，进入管理端审核队列）。发布 +5 积分。

#### POST `/api/posts/:id/like` 点赞 / 取消（需登录）

幂等切换：已赞则取消，未赞则点赞。
响应 `data`：`{ "liked": true, "likeCount": 15 }`

#### POST `/api/posts/:id/collect` 收藏 / 取消（需登录）

响应 `data`：`{ "collected": true }`

#### POST `/api/posts/:id/close` 关闭动态（需登录 + 本人）

仅发布者本人可关闭。响应 `data`：`Post`（`status=closed`）。

#### GET `/api/posts/:id/comments` 评论列表

响应 `data`：`[Comment]`

#### POST `/api/posts/:id/comments` 发表评论（需登录）

请求体：`{ "content": "……", "parentId": "可选，回复的评论id", "replyToUserId": "可选" }`

规则：内容 ≤ 200 字；楼中楼最多 2 层（`parentId` 的父评论必须是顶层）。响应 `data`：`Comment`（新评论）。

#### POST `/api/posts/:id/report` 举报动态（需登录）

请求体：`{ "reason": "fake", "description": "……" }`（reason 见 2.4）
响应 `data`：`{ "ok": true }`

---

### 3.3 管理端 Admin — `/api/admin`（全部需管理员）

> 非管理员访问返回 `403 无权限`。

#### GET `/api/admin/audits` 待审核列表

查询：`page` / `size`。
响应 `data`：`{ "list": [Post], "total", "page", "size", "hasMore" }`（`audit_status=pending`，按提交时间升序）

#### POST `/api/admin/audits/:id/approve` 审核通过

响应 `data`：`Post`（`audit_status=approved`，`status=processing`，进入公开列表）

#### POST `/api/admin/audits/:id/reject` 审核驳回

请求体：`{ "reason": "信息不完整" }`（必填）
响应 `data`：`Post`（`audit_status=rejected`，`status` 保持 `pending`，`rejectReason` 写入理由；发布者在「我的发布-待审核」看到驳回原因）

#### GET `/api/admin/reports` 举报列表

查询：`status`（可选）、`page` / `size`。
响应 `data`：`{ "list": [Report], "total", ... }`

#### POST `/api/admin/reports/:id/handle` 处理举报

请求体：`{ "status": "warned", "result": "已警告" }`
`status` 取值：`dismissed` 驳回 / `warned` 警告 / `deleted` 删除动态 / `frozen` 冻结用户。
响应 `data`：`{ "ok": true }`

#### GET `/api/admin/users` 用户列表

查询：`role`（可选）、`keyword`（昵称/手机号/学工号模糊）、`page` / `size`。
响应 `data`：`{ "list": [{ id, phone, nickname, role, department, campus, creditScore, status, createdAt }], ... }`

---

### 3.4 用户 User — `/api/users`

#### GET `/api/users/me/posts` 我的发布（需登录）

查询：`status`（可选）、`page` / `size`。

| status | 返回 |
|--------|------|
| `pending` | 待审核 + 被驳回（含 `rejectReason`） |
| `processing` | 进行中 |
| `resolved` | 已完结 |
| `closed` | 已关闭 |

响应 `data`：`{ "list": [Post], ... }`

#### PUT `/api/users/me` 更新资料（需登录）

请求体：`{ "nickname": "新昵称", "campus": "东校区", "department": "外语学院" }`（均为可选，传则更新）
响应 `data`：用户信息

#### GET `/api/users/:id` 公开主页

响应 `data`：`{ id, nickname, avatar, role, department, campus, creditScore }`

#### GET `/api/users/:id/posts` 该用户发布的动态

响应 `data`：`{ "list": [Post] }`

---

### 3.5 认领 / 线索（前端次要模块，接口已就绪）

#### GET `/api/claims` 我的认领记录（需登录）
响应 `data`：`{ "list": [{ id, postTitle, applicant, desc, status, time }] }`

#### POST `/api/claims` 提交认领（需登录）
请求体：`{ "postId": "p1", "description": "……", "verifyAnswer": "……" }`

#### GET `/api/clues` 我的线索（需登录）
响应 `data`：`{ "list": [{ id, postTitle, desc, status, time }] }`

#### POST `/api/clues` 提交线索（需登录）
请求体：`{ "postId": "p2", "content": "……" }`

---

### 3.6 消息 / 会话（前端次要模块，接口已就绪）

#### GET `/api/messages` 我的私信（需登录）
响应 `data`：`{ "list": [{ id, type:"chat", title:对方昵称, content, time, unread }] }`

#### PUT `/api/messages/:id/read` 标记已读（需登录）

#### GET `/api/chats` 会话列表（需登录）
响应 `data`：`{ "list": [{ id, name, lastMsg, time, unread, messages:[{ me, content, time }] }] }`

#### POST `/api/chats/:peerId` 发送私信（需登录）
请求体：`{ "content": "……" }`

---

### 3.7 积分 / 分类 / 健康检查

#### GET `/api/credit/logs` 我的积分明细（需登录）
响应 `data`：`{ "balance": 102, "level": 3, "logs": [{ id, event, delta, balance, time }] }`

#### GET `/api/categories` 分类列表
响应 `data`：`{ "list": [{ key, name, icon, sub:["校园卡","身份证",...] }] }`（8 大分类，与前端 CATEGORIES 对齐）

#### GET `/api/health` 健康检查
响应 `data`：`{ "ok": true, "time": "2026-08-04T..." }`

#### 静态资源

```
GET /static/images/p1.png
```

动态图片以相对路径返回（`/static/images/xxx.png`），`express.static` 托管。

---

## 四、演示流程（curl）

```bash
B=http://127.0.0.1:3000

# 1. 学生登录拿 token
TOK=$(curl -s -X POST $B/api/auth/login -H 'Content-Type: application/json' \
  -d '{"phone":"13800000002","password":"123456"}' | python -c "import sys,json;print(json.load(sys.stdin)['data']['token'])")

# 2. 动态列表（第 1 页 3 条）
curl -s "$B/api/posts?page=1&size=3"

# 3. 关键词搜索（空格分词 AND）
curl -s "$B/api/posts?keyword=%E5%9B%BE%E4%B9%A6%E9%A6%86"

# 4. 点赞 / 收藏 / 评论（带 token）
curl -s -X POST $B/api/posts/p1/like -H "Authorization: Bearer $TOK"
curl -s -X POST $B/api/posts/p1/collect -H "Authorization: Bearer $TOK"
curl -s -X POST $B/api/posts/p1/comments -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' -d '{"content":"测试评论"}'

# 5. 发布动态（进审核）
curl -s -X POST $B/api/posts -H "Authorization: Bearer $TOK" -H 'Content-Type: application/json' \
  -d '{"type":"lost","title":"测试校园卡","desc":"测试描述","category":"card","categoryName":"证件卡类","location":"图书馆"}'

# 6. 管理员登录并审核通过
ATOK=$(curl -s -X POST $B/api/auth/login -H 'Content-Type: application/json' \
  -d '{"phone":"13800000001","password":"admin123"}' | python -c "import sys,json;print(json.load(sys.stdin)['data']['token'])")
curl -s "$B/api/admin/audits" -H "Authorization: Bearer $ATOK"
curl -s -X POST $B/api/admin/audits/p25/approve -H "Authorization: Bearer $ATOK"
```

---

## 五、演示账号

| 账号 | 密码 | 角色 |
|------|------|------|
| `13800000001` | `admin123` | 管理员（admin） |
| `13800000002` | `123456` | 学生（student 小南） |
| `13800000003` | `123456` | 教师（teacher 阿诚） |
| `13800000004` | `123456` | 教职工（staff 王老师） |

---

## 六、前端对接映射

| ApiRepo 方法 | 接口 |
|-------------|------|
| `getPosts` | GET `/api/posts` |
| `getPost` | GET `/api/posts/:id` |
| `addPost` | POST `/api/posts` |
| `toggleLike` | POST `/api/posts/:id/like` |
| `toggleCollect` | POST `/api/posts/:id/collect` |
| `closePost` | POST `/api/posts/:id/close` |
| `addComment` | POST `/api/posts/:id/comments` |
| `myPosts` | GET `/api/users/me/posts` |
| `login` / `register` / `me` | POST `/api/auth/login` / `/register`、GET `/api/auth/me` |
| `fetchAudits` / `approveAudit` / `rejectAudit` | GET/POST `/api/admin/audits*` |
| `fetchReports` / `handleReport` | GET `/api/admin/reports*` |
| `fetchUsers` | GET `/api/admin/users` |

---

## 附录 A：变更记录

| 版本 | 日期 | 变更内容 | 变更人 |
|------|------|----------|--------|
| v1.0 | 2026-08-04 | 首次发布，对齐 `server/` 实现（11 表 + 全量 CRUD） | AI Agent |
