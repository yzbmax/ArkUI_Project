/**
 * MySQL 连接池（harmony 库）
 * 环境变量可覆盖默认值：DB_HOST / DB_PORT / DB_USER / DB_PASS / DB_NAME
 */
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASS || 'root',
  database: process.env.DB_NAME || 'harmony',
  waitForConnections: true,
  connectionLimit: 10,
  dateStrings: true,
  charset: 'utf8mb4'
});

/** 查询助手：SELECT/INSERT/UPDATE/DELETE 均返回 rows（INSERT 返回 ResultSetHeader） */
async function query(sql, params) {
  const [rows] = await pool.query(sql, params);
  return rows;
}

/** 事务助手：执行 fn(conn)，成功 commit，失败 rollback */
async function transaction(fn) {
  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();
    const result = await fn(conn);
    await conn.commit();
    return result;
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    conn.release();
  }
}

module.exports = { pool, query, transaction };
