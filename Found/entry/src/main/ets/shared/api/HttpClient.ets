/**
 * HTTP 客户端（A006）—— 基于 @kit.NetworkKit http 模块
 * - 统一响应信封 { code, message, data }：code=0 成功，非 0 抛 ApiError
 * - Token 自动注入（读取 AppStorage['token']，由 AppStore 登录时写入）
 * - BASE_URL：模拟器用 10.0.2.2（映射宿主机回环）；真机改为 PC 局域网 IP
 */
import { http } from '@kit.NetworkKit';

/** 模拟器地址：10.0.2.2 映射宿主机 127.0.0.1（已验证可用）；真机改为 PC 局域网 IP（手机与 PC 同网段） */
export const BASE_URL: string = 'http://10.0.2.2:3000';
/** DB 中图片存相对路径，映射时拼此前缀得到完整 URL */
export const IMG_PREFIX: string = BASE_URL;

/** 业务错误（带业务码） */
export class ApiError extends Error {
  code: number;

  constructor(code: number, message: string) {
    super(message);
    this.code = code;
  }
}

/** 响应信封。ArkTS 需显式接口承接 JSON。 */
interface ApiEnvelope {
  code: number;
  message: string;
  data: object;
}

/** 请求头。ArkTS 不允许无类型对象字面量，用显式接口。 */
interface ReqHeader {
  'Content-Type': string;
  'Authorization'?: string;
}

export class HttpClient {
  static async request<T>(method: http.RequestMethod, path: string, body?: object): Promise<T> {
    const req = http.createHttp();
    try {
      const header: ReqHeader = { 'Content-Type': 'application/json' };
      const tk: string = AppStorage.get<string>('token') ?? '';
      if (tk !== '') {
        header.Authorization = 'Bearer ' + tk;
      }
      const resp: http.HttpResponse = await req.request(BASE_URL + path, {
        method: method,
        header: header,
        extraData: body ? JSON.stringify(body) : undefined,
        connectTimeout: 10000,
        readTimeout: 15000
      });
      if (resp.responseCode !== 200) {
        // 后端错误响应同样携带 { code, message }，解析出可读的业务提示（如"密码错误"）
        let msg: string = 'HTTP ' + resp.responseCode;
        try {
          const errRaw = JSON.parse(resp.result.toString()) as ApiEnvelope;
          if (errRaw && errRaw.message) {
            msg = errRaw.message;
          }
        } catch (e) {
          // 非 JSON 响应，沿用默认提示
        }
        throw new ApiError(resp.responseCode, msg);
      }
      const raw: ApiEnvelope = JSON.parse(resp.result.toString()) as ApiEnvelope;
      if (raw.code !== 0) {
        throw new ApiError(raw.code, raw.message);
      }
      return raw.data as T;
    } catch (e) {
      const err = e as Error;
      if (err instanceof ApiError) {
        throw err;
      }
      throw new ApiError(-1, '网络异常：' + err.message);
    } finally {
      req.destroy();
    }
  }

  static get<T>(path: string): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.GET, path);
  }

  static post<T>(path: string, body?: object): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.POST, path, body);
  }

  static put<T>(path: string, body?: object): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.PUT, path, body);
  }

  static delete<T>(path: string): Promise<T> {
    return HttpClient.request<T>(http.RequestMethod.DELETE, path);
  }
}
