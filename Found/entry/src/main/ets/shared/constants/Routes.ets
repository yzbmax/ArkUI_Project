/**
 * 路由表（A008）—— PRD 28 页面路由名。
 * ArkTS 不支持 as const / 无类型对象字面量 / typeof 类型查询 / 索引访问类型，
 * 因此改为显式类 + 只读静态字段。
 */
export class ROUTES {
  static readonly splash: string = 'pages/Splash';
  static readonly login: string = 'pages/Login';
  static readonly register: string = 'pages/Register';
  static readonly forgot: string = 'pages/ForgotPassword';
  static readonly home: string = 'pages/MainTab';
  static readonly search: string = 'pages/SearchPage';
  static readonly category: string = 'pages/Category';
  static readonly lostDetail: string = 'pages/PostDetail';
  static readonly publishLost: string = 'pages/PublishLost';
  static readonly publishFound: string = 'pages/PublishFound';
  static readonly match: string = 'pages/Match';
  static readonly chat: string = 'pages/Chat';
  static readonly claim: string = 'pages/ClaimForm';
  static readonly clue: string = 'pages/ClueForm';
  static readonly claimReview: string = 'pages/ClaimReview';
  static readonly clueReview: string = 'pages/ClueReview';
  static readonly myPosts: string = 'pages/MyPosts';
  static readonly myClaims: string = 'pages/MyClaims';
  static readonly favorites: string = 'pages/Favorites';
  static readonly credit: string = 'pages/Credit';
  static readonly settings: string = 'pages/Settings';
  static readonly editProfile: string = 'pages/EditProfile';
  static readonly admin: string = 'pages/Admin';
}

/** 路由名类型。ArkTS 无法由对象推导字面量联合类型，退化为 string。 */
export type RouteName = string;
