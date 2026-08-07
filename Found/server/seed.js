/**
 * 建表 + 种子数据（幂等，可重复执行）
 * 用法：npm run seed
 */
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const bcrypt = require('bcryptjs');
const { pool } = require('./db');

/* ============ 纯色 PNG 生成（占位图，无第三方依赖） ============ */
function crc32(buf) {
  let c;
  let table = crc32.table;
  if (!table) {
    table = crc32.table = [];
    for (let n = 0; n < 256; n++) {
      c = n;
      for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      table[n] = c >>> 0;
    }
  }
  c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = table[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
function pngChunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crcBuf = Buffer.alloc(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crcBuf]);
}
function solidPng(width, height, r, g, b) {
  const sig = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // 位深
  ihdr[9] = 2; // RGB
  const raw = Buffer.alloc(height * (1 + width * 3));
  for (let y = 0; y < height; y++) {
    const off = y * (1 + width * 3);
    raw[off] = 0; // filter none
    for (let x = 0; x < width; x++) {
      raw[off + 1 + x * 3] = r;
      raw[off + 2 + x * 3] = g;
      raw[off + 3 + x * 3] = b;
    }
  }
  const idat = zlib.deflateSync(raw);
  return Buffer.concat([sig, pngChunk('IHDR', ihdr), pngChunk('IDAT', idat), pngChunk('IEND', Buffer.alloc(0))]);
}

/* ============ 建表 DDL（对齐 PRD 7.2 + 扩展表） ============ */
const DDL = [
  // user
  `CREATE TABLE IF NOT EXISTS \`user\` (
    id VARCHAR(36) PRIMARY KEY,
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(64),
    password_hash VARCHAR(100) NOT NULL,
    nickname VARCHAR(32) NOT NULL UNIQUE,
    avatar VARCHAR(255) DEFAULT '',
    real_name VARCHAR(32),
    student_id VARCHAR(32),
    role ENUM('student','teacher','staff','admin') NOT NULL DEFAULT 'student',
    department VARCHAR(64),
    campus VARCHAR(32) NOT NULL DEFAULT '中心校区',
    grade VARCHAR(16),
    credit_score INT NOT NULL DEFAULT 0,
    status ENUM('normal','frozen','deleted') NOT NULL DEFAULT 'normal',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // post
  `CREATE TABLE IF NOT EXISTS post (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('lost','found') NOT NULL,
    category VARCHAR(32) NOT NULL,
    category_name VARCHAR(32) NOT NULL,
    title VARCHAR(64) NOT NULL,
    description TEXT,
    images JSON,
    location VARCHAR(128),
    location_tag VARCHAR(32),
    occurred_at DATETIME,
    contact VARCHAR(64),
    contact_type ENUM('pm','phone','wechat') NOT NULL DEFAULT 'phone',
    reward VARCHAR(32),
    urgency ENUM('normal','urgent') NOT NULL DEFAULT 'normal',
    is_anonymous TINYINT(1) NOT NULL DEFAULT 0,
    verify_question VARCHAR(255),
    status ENUM('pending','processing','resolved','closed') NOT NULL DEFAULT 'pending',
    audit_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    audit_remark VARCHAR(255),
    view_count INT NOT NULL DEFAULT 0,
    like_count INT NOT NULL DEFAULT 0,
    comment_count INT NOT NULL DEFAULT 0,
    share_count INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_post_user (user_id),
    KEY idx_post_status (status),
    KEY idx_post_audit (audit_status),
    KEY idx_post_type (type),
    KEY idx_post_cat (category),
    KEY idx_post_created (created_at),
    KEY idx_post_urgent (urgency),
    CONSTRAINT fk_post_user FOREIGN KEY (user_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // comment
  `CREATE TABLE IF NOT EXISTS comment (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    content VARCHAR(500) NOT NULL,
    parent_id VARCHAR(36) NULL,
    reply_to_user_id VARCHAR(36) NULL,
    like_count INT NOT NULL DEFAULT 0,
    status ENUM('normal','hidden','deleted') NOT NULL DEFAULT 'normal',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_cmt_post (post_id),
    KEY idx_cmt_parent (parent_id),
    KEY idx_cmt_user (user_id),
    CONSTRAINT fk_cmt_post FOREIGN KEY (post_id) REFERENCES post(id),
    CONSTRAINT fk_cmt_user FOREIGN KEY (user_id) REFERENCES \`user\`(id),
    CONSTRAINT fk_cmt_parent FOREIGN KEY (parent_id) REFERENCES comment(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // like（保留字，反引号）
  `CREATE TABLE IF NOT EXISTS \`like\` (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    target_id VARCHAR(36) NOT NULL,
    target_type ENUM('post','comment') NOT NULL DEFAULT 'post',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_like (user_id, target_id, target_type),
    KEY idx_like_target (target_id, target_type),
    CONSTRAINT fk_like_user FOREIGN KEY (user_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // collect（扩展表）
  `CREATE TABLE IF NOT EXISTS collect (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    post_id VARCHAR(36) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_collect (user_id, post_id),
    CONSTRAINT fk_col_user FOREIGN KEY (user_id) REFERENCES \`user\`(id),
    CONSTRAINT fk_col_post FOREIGN KEY (post_id) REFERENCES post(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // claim
  `CREATE TABLE IF NOT EXISTS claim (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    claimant_id VARCHAR(36) NOT NULL,
    description TEXT,
    verify_answer VARCHAR(255),
    status ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    KEY idx_claim_post (post_id),
    KEY idx_claim_user (claimant_id),
    CONSTRAINT fk_claim_post FOREIGN KEY (post_id) REFERENCES post(id),
    CONSTRAINT fk_claim_user FOREIGN KEY (claimant_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // clue
  `CREATE TABLE IF NOT EXISTS clue (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    provider_id VARCHAR(36) NOT NULL,
    content TEXT,
    images JSON,
    is_helpful TINYINT(1) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_clue_post (post_id),
    KEY idx_clue_provider (provider_id),
    CONSTRAINT fk_clue_post FOREIGN KEY (post_id) REFERENCES post(id),
    CONSTRAINT fk_clue_user FOREIGN KEY (provider_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // message（私信）
  `CREATE TABLE IF NOT EXISTS message (
    id VARCHAR(36) PRIMARY KEY,
    from_user_id VARCHAR(36) NOT NULL,
    to_user_id VARCHAR(36) NOT NULL,
    content VARCHAR(500),
    msg_type ENUM('text','image') NOT NULL DEFAULT 'text',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_msg_to (to_user_id, is_read),
    KEY idx_msg_from (from_user_id),
    CONSTRAINT fk_msg_from FOREIGN KEY (from_user_id) REFERENCES \`user\`(id),
    CONSTRAINT fk_msg_to FOREIGN KEY (to_user_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // credit_log
  `CREATE TABLE IF NOT EXISTS credit_log (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    \`change\` INT NOT NULL,
    event_type ENUM('register','post','return','find','clue','thank','reported','fraud','timeout') NOT NULL,
    description VARCHAR(255),
    balance INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_cl_user (user_id),
    CONSTRAINT fk_cl_user FOREIGN KEY (user_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // notif_read（消息中心已读记录：用户 × 通知类型）
  `CREATE TABLE IF NOT EXISTS notif_read (
    user_id VARCHAR(36) NOT NULL,
    type VARCHAR(20) NOT NULL,
    read_at DATETIME DEFAULT NULL,
    PRIMARY KEY (user_id, type)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // report
  `CREATE TABLE IF NOT EXISTS report (
    id VARCHAR(36) PRIMARY KEY,
    reporter_id VARCHAR(36) NOT NULL,
    target_id VARCHAR(36) NOT NULL,
    target_type ENUM('post','comment','user') NOT NULL,
    reason ENUM('fake','fraud','harass','inappropriate','other') NOT NULL,
    description VARCHAR(500),
    status ENUM('pending','dismissed','warned','deleted','frozen') NOT NULL DEFAULT 'pending',
    handler_id VARCHAR(36),
    result VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    handled_at DATETIME,
    KEY idx_rep_status (status),
    KEY idx_rep_target (target_id, target_type),
    CONSTRAINT fk_rep_user FOREIGN KEY (reporter_id) REFERENCES \`user\`(id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`,
  // category（扩展表，对齐前端 CATEGORIES）
  `CREATE TABLE IF NOT EXISTS category (
    cat_key VARCHAR(32) PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    icon VARCHAR(32),
    sub JSON,
    sort INT NOT NULL DEFAULT 0
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`
];

/* ============ 分类（与前端 Constants.CATEGORIES 完全一致） ============ */
const CATEGORIES = [
  { key: 'card', name: '证件卡类', icon: 'id', sub: ['校园卡', '身份证', '学生证', '其他证件'] },
  { key: 'digital', name: '电子数码', icon: 'smartphone', sub: ['手机', '耳机', '平板', '充电宝', '其他数码'] },
  { key: 'key', name: '钥匙钱包', icon: 'key', sub: ['钥匙', '钱包', '卡包', '其他'] },
  { key: 'book', name: '书本文具', icon: 'book', sub: ['教材', '笔记本', '文具', '其他'] },
  { key: 'clothes', name: '衣物配饰', icon: 'shirt', sub: ['外套', '帽子', '眼镜', '其他'] },
  { key: 'sport', name: '运动器材', icon: 'ball_volleyball', sub: ['球类', '球拍', '护具', '其他'] },
  { key: 'life', name: '生活用品', icon: 'cup', sub: ['水杯', '雨伞', '化妆品', '其他'] },
  { key: 'other', name: '其他', icon: 'grid_dots', sub: ['不详', '其他'] }
];
const CAT_NAMES = Object.fromEntries(CATEGORIES.map((c) => [c.key, c.name]));
const LOCATIONS = ['图书馆', '食堂', '教学楼', '操场', '宿舍'];
const AUTHORS = ['小南', '阿诚', '林同学', '王同学', '张三'];
const IMG_COLORS = [
  [201, 100, 66], [217, 119, 87], [110, 139, 94], [94, 139, 94],
  [201, 146, 62], [94, 91, 87], [181, 51, 51], [56, 152, 236]
];

/** 相对当前时间的偏移（分钟） */
function ago(minutes) {
  return new Date(Date.now() - minutes * 60 * 1000);
}
function fmt(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

/* ============ 主流程 ============ */
async function main() {
  const conn = await pool.getConnection();
  try {
    // 1. 建表
    for (const sql of DDL) {
      await conn.query(sql);
    }
    console.log('✓ 建表完成（11 张）');

    // 2. 静态占位图
    const imgDir = path.join(__dirname, 'static', 'images');
    fs.mkdirSync(imgDir, { recursive: true });
    for (let i = 1; i <= 24; i++) {
      const [r, g, b] = IMG_COLORS[(i - 1) % IMG_COLORS.length];
      fs.writeFileSync(path.join(imgDir, `p${i}.png`), solidPng(320, 200, r, g, b));
    }
    console.log('✓ 占位图生成（24 张）');

    // 3. 用户（幂等：按 phone 查重）
    const users = [
      { phone: '13800000001', password: 'admin123', nickname: '管理员', realName: '系统管理员', studentId: 'A00001', role: 'admin', department: '信息中心', campus: '中心校区', credit: 500 },
      { phone: '13800000002', password: '123456', nickname: '小南', realName: '张南', studentId: '20240101', role: 'student', department: '计算机学院', campus: '中心校区', credit: 132 },
      { phone: '13800000003', password: '123456', nickname: '阿诚', realName: '李诚', studentId: '20220102', role: 'teacher', department: '外国语学院', campus: '东校区', credit: 86 },
      { phone: '13800000004', password: '123456', nickname: '王老师', realName: '王芳', studentId: 'T30001', role: 'staff', department: '后勤保障处', campus: '主校区', credit: 40 }
    ];
    const userIds = {};
    for (const u of users) {
      const exist = await conn.query('SELECT id FROM `user` WHERE phone = ?', [u.phone]);
      if (exist[0].length > 0) {
        userIds[u.phone] = exist[0][0].id;
        continue;
      }
      const id = require('./utils').uuid();
      const hash = bcrypt.hashSync(u.password, 10);
      await conn.query(
        'INSERT INTO `user` (id, phone, password_hash, nickname, real_name, student_id, role, department, campus, credit_score, status) VALUES (?,?,?,?,?,?,?,?,?,?,?)',
        [id, u.phone, hash, u.nickname, u.realName, u.studentId, u.role, u.department, u.campus, u.credit, 'normal']
      );
      await conn.query(
        'INSERT INTO credit_log (id, user_id, `change`, event_type, description, balance, created_at) VALUES (?,?,?,?,?,?,?)',
        [require('./utils').uuid(), id, 20, 'register', '注册奖励', 20, fmt(ago(60 * 24 * 30))] // 注册奖励（历史）
      );
      userIds[u.phone] = id;
    }
    console.log('✓ 用户种子完成（4 个）');

    // 4. post（复刻 MockRepo.mkPost 循环逻辑）
    const statusCycle = ['processing', 'pending', 'resolved', 'closed'];
    const uidList = Object.values(userIds);
    const postRows = [];
    const commentSeed = []; // 待评论
    for (let i = 1; i <= 24; i++) {
      const type = i % 2 === 1 ? 'lost' : 'found'; // 与 Mock 一致：i%2==0 → FOUND
      const cat = ['card', 'digital', 'key', 'book', 'clothes', 'sport', 'life', 'other'][i % 8];
      const catName = CAT_NAMES[cat];
      const st = statusCycle[i % 4];
      const isPending = st === 'pending';
      const postId = 'p' + i;
      const images = [`/static/images/p${i}.png`];
      const occurred = ago(10 + i * 180); // 越后越早
      postRows.push({
        id: postId,
        user_id: uidList[(i - 1) % uidList.length],
        type,
        category: cat,
        category_name: catName,
        title: (type === 'lost' ? '捡到' : '丢失') + catName,
        description: `大概在${LOCATIONS[i % 5]}三层自习区${type === 'lost' ? '捡到' : '丢失'}的，希望尽快物归原主，请联系我。`,
        images: JSON.stringify(images),
        location: LOCATIONS[i % 5],
        occurred_at: fmt(occurred),
        contact: 'App 内私信',
        reward: i % 3 === 0 ? '奶茶一杯' : '',
        urgency: i % 4 === 0 ? 'urgent' : 'normal',
        is_anonymous: 0,
        status: st,
        audit_status: isPending ? 'pending' : 'approved',
        audit_remark: '',
        like_count: (i * 7) % 50,
        comment_count: st === 'processing' ? 1 : 0,
        created_at: fmt(ago(10 + i * 180))
      });
      if (st === 'processing') {
        commentSeed.push({ postId, authorUid: uidList[(i + 1) % uidList.length] });
      }
    }
    for (const r of postRows) {
      const exist = await conn.query('SELECT id FROM post WHERE id = ?', [r.id]);
      if (exist[0].length === 0) {
        await conn.query(
          'INSERT INTO post (id, user_id, type, category, category_name, title, description, images, location, occurred_at, contact, reward, urgency, status, audit_status, like_count, comment_count, created_at) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
          [r.id, r.user_id, r.type, r.category, r.category_name, r.title, r.description, r.images, r.location, r.occurred_at, r.contact, r.reward, r.urgency, r.status, r.audit_status, r.like_count, r.comment_count, r.created_at]
        );
      }
    }
    console.log('✓ post 种子完成（24 条）');

    // 5. 评论（processing 帖各 1 条顶层 + 1 条带回复）
    for (const s of commentSeed) {
      const topId = require('./utils').uuid();
      const topExist = await conn.query('SELECT id FROM comment WHERE post_id = ?', [s.postId]);
      if (topExist[0].length === 0) {
        await conn.query(
          'INSERT INTO comment (id, post_id, user_id, content, parent_id, created_at) VALUES (?,?,?,?,?,?)',
          [topId, s.postId, s.authorUid, '我在现场看到过，可以帮忙确认一下～', null, fmt(ago(60))]
        );
        await conn.query(
          'INSERT INTO comment (id, post_id, user_id, content, parent_id, reply_to_user_id, created_at) VALUES (?,?,?,?,?,?,?)',
          [require('./utils').uuid(), s.postId, uidList[(uidList.indexOf(s.authorUid) + 1) % uidList.length], '好的，谢谢你！', topId, s.authorUid, fmt(ago(50))]
        );
      }
    }
    console.log('✓ 评论种子完成');

    // 6. like / collect（演示用户小南 对前 10 条）
    const xiaonan = userIds['13800000002'];
    for (let i = 1; i <= 10; i++) {
      const pid = 'p' + i;
      const l = await conn.query('SELECT id FROM `like` WHERE user_id = ? AND target_id = ? AND target_type = ?', [xiaonan, pid, 'post']);
      if (l[0].length === 0) {
        await conn.query('INSERT INTO `like` (id, user_id, target_id, target_type) VALUES (?,?,?,?)', [require('./utils').uuid(), xiaonan, pid, 'post']);
      }
      const c = await conn.query('SELECT id FROM collect WHERE user_id = ? AND post_id = ?', [xiaonan, pid]);
      if (c[0].length === 0) {
        await conn.query('INSERT INTO collect (id, user_id, post_id) VALUES (?,?,?)', [require('./utils').uuid(), xiaonan, pid]);
      }
    }
    console.log('✓ like / collect 种子完成');

    // 7. claim / clue（复刻 Mock c1~c4 / l1~l3）
    const claims = [
      { postTitle: '捡到校园卡', applicant: '李同学', desc: '我在图书馆捡到的，能详细描述颜色和挂绳', status: 'pending' },
      { postTitle: '丢失耳机', applicant: '赵同学', desc: '是我上周买的，可提供购买记录', status: 'approved' },
      { postTitle: '捡到钥匙', applicant: '钱同学', desc: '描述相符，请核实', status: 'rejected' },
      { postTitle: '丢失水杯', applicant: '孙同学', desc: '想确认一下', status: 'cancelled' }
    ];
    for (const c of claims) {
      const exist = await conn.query('SELECT id FROM claim WHERE description = ?', [c.desc]);
      if (exist[0].length === 0) {
        await conn.query('INSERT INTO claim (id, post_id, claimant_id, description, status, created_at) VALUES (?,?,?,?,?,?)',
          [require('./utils').uuid(), 'p1', xiaonan, c.desc, c.status, fmt(ago(60))]);
      }
    }
    const clues = [
      { postTitle: '丢失手机', desc: '我在失物招领处看到过类似的', status: 'valid' },
      { postTitle: '丢失雨伞', desc: '可能是蓝色那把', status: 'invalid' },
      { postTitle: '丢失钱包', desc: '在食堂捡到，已上交', status: 'pending' }
    ];
    for (const c of clues) {
      const exist = await conn.query('SELECT id FROM clue WHERE content = ?', [c.desc]);
      if (exist[0].length === 0) {
        await conn.query('INSERT INTO clue (id, post_id, provider_id, content, is_helpful, created_at) VALUES (?,?,?,?,?,?)',
          [require('./utils').uuid(), 'p2', uidList[2], c.desc, c.status === 'valid' ? 1 : (c.status === 'invalid' ? 0 : null), fmt(ago(60))]);
      }
    }
    console.log('✓ claim / clue 种子完成');

    // 8. message（两名用户互发私信）
    const msgPairs = [
      [uidList[0], xiaonan, '你好，请问东西还在吗？', 0],
      [xiaonan, uidList[0], '在的，你在哪捡到的呀', 0],
      [uidList[0], xiaonan, '图书馆三层，可以今天来取', 1],
      [uidList[2], xiaonan, '感谢你捡到我的卡', 0]
    ];
    for (const [from, to, content, read] of msgPairs) {
      const exist = await conn.query('SELECT id FROM message WHERE from_user_id = ? AND to_user_id = ? AND content = ?', [from, to, content]);
      if (exist[0].length === 0) {
        await conn.query('INSERT INTO message (id, from_user_id, to_user_id, content, is_read, created_at) VALUES (?,?,?,?,?,?)',
          [require('./utils').uuid(), from, to, content, read, fmt(ago(30))]);
      }
    }
    console.log('✓ message 种子完成');

    // 9. credit_log（对齐 user.credit_score 演进）
    const logs = [
      { user: xiaonan, change: 20, evt: 'register', desc: '注册奖励', balance: 20, t: 30 },
      { user: xiaonan, change: 5, evt: 'post', desc: '发布动态', balance: 25, t: 25 },
      { user: xiaonan, change: 10, evt: 'clue', desc: '提供有效线索', balance: 35, t: 20 },
      { user: xiaonan, change: 30, evt: 'return', desc: '成功归还物品', balance: 65, t: 15 },
      { user: xiaonan, change: 30, evt: 'return', desc: '成功归还物品', balance: 95, t: 10 },
      { user: xiaonan, change: 5, evt: 'post', desc: '发布动态', balance: 100, t: 5 },
      { user: xiaonan, change: 2, evt: 'post', desc: '发布动态', balance: 102, t: 1 }
    ];
    for (const l of logs) {
      const exist = await conn.query('SELECT id FROM credit_log WHERE user_id = ? AND balance = ?', [l.user, l.balance]);
      if (exist[0].length === 0) {
        await conn.query('INSERT INTO credit_log (id, user_id, `change`, event_type, description, balance, created_at) VALUES (?,?,?,?,?,?,?)',
          [require('./utils').uuid(), l.user, l.change, l.evt, l.desc, l.balance, fmt(ago(l.t * 1440))]);
      }
    }
    console.log('✓ credit_log 种子完成');

    // 10. report（复刻 Mock r1/r2）
    const reports = [
      { targetId: 'p3', reason: 'fake', desc: '垃圾广告', status: 'pending' },
      { targetId: xiaonan, reason: 'harass', desc: '骚扰私信', status: 'dismissed', targetType: 'user' }
    ];
    for (const r of reports) {
      const exist = await conn.query('SELECT id FROM report WHERE target_id = ? AND description = ?', [r.targetId, r.desc]);
      if (exist[0].length === 0) {
        await conn.query('INSERT INTO report (id, reporter_id, target_id, target_type, reason, description, status, created_at) VALUES (?,?,?,?,?,?,?,?)',
          [require('./utils').uuid(), uidList[1], r.targetId, r.targetType || 'post', r.reason, r.desc, r.status, fmt(ago(60))]);
      }
    }
    console.log('✓ report 种子完成');

    // 11. category
    for (let i = 0; i < CATEGORIES.length; i++) {
      const c = CATEGORIES[i];
      await conn.query('INSERT INTO category (cat_key, name, icon, sub, sort) VALUES (?,?,?,?,?) ON DUPLICATE KEY UPDATE name=VALUES(name), icon=VALUES(icon), sub=VALUES(sub), sort=VALUES(sort)',
        [c.key, c.name, c.icon, JSON.stringify(c.sub), i]);
    }
    console.log('✓ category 种子完成（8 行）');

    console.log('\n✅ 种子完成，共 11 张表 + 24 post + 4 用户');
    console.log('登录演示：13800000001/admin123（管理员）、13800000002/123456（学生）');
  } catch (e) {
    console.error('❌ 种子失败：', e);
    process.exitCode = 1;
  } finally {
    conn.release();
    await pool.end();
  }
}

main();
