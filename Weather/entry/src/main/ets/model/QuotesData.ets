/**
 * 哲言库 - 内置50+条温暖诗意短句
 * 按时间段分类，每日随机选择一条
 */

export interface QuoteItem {
  text: string;
  author: string;
  periods: string[]; // 适合的时间段: morning, noon, afternoon, night
}

export const QUOTES_LIBRARY: QuoteItem[] = [
  { text: '万物皆有裂痕，那是光照进来的地方。', author: '莱昂纳德·科恩', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '你眼里的星光，胜过一切我见过的山川与河流。', author: '佚名', periods: ['night'] },
  { text: '生活不是等待暴风雨过去，而是学会在雨中起舞。', author: '佚名', periods: ['afternoon', 'night'] },
  { text: '每一次日出，都是世界对你说的早安。', author: '佚名', periods: ['morning'] },
  { text: '风起的时候，树叶在写诗。', author: '佚名', periods: ['morning', 'afternoon'] },
  { text: '你比想象中更勇敢，比昨天更接近光。', author: '佚名', periods: ['morning', 'noon'] },
  { text: '月亮从不问为什么，它只是按时升起。', author: '佚名', periods: ['night'] },
  { text: '时间是一条温柔的河流，带走了沙粒，留下了金子。', author: '佚名', periods: ['afternoon', 'night'] },
  { text: '你走过的路，每一步都算数。', author: '佚名', periods: ['morning', 'noon', 'afternoon'] },
  { text: '把心事交给风，它比谁都擅长遗忘。', author: '佚名', periods: ['noon', 'afternoon'] },
  { text: '世界很大，大到可以容纳所有的梦。', author: '佚名', periods: ['morning'] },
  { text: '微光也是光，足以照亮脚下的路。', author: '佚名', periods: ['morning', 'night'] },
  { text: '最美的风景，往往在不经意的转角。', author: '佚名', periods: ['noon', 'afternoon'] },
  { text: '心若向阳，无惧悲伤。', author: '佚名', periods: ['morning', 'noon'] },
  { text: '雨停了，天空会记得每一滴雨的故事。', author: '佚名', periods: ['afternoon'] },
  { text: '你是宇宙写给这个世界的一封情书。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '星光不问赶路人，时光不负有心人。', author: '佚名', periods: ['night', 'morning'] },
  { text: '在平凡的日子里，开出花来。', author: '佚名', periods: ['morning', 'noon'] },
  { text: '温柔地对待这个世界，它也会温柔待你。', author: '佚名', periods: ['morning', 'noon', 'afternoon'] },
  { text: '所有的偶然，都是命运的精心安排。', author: '佚名', periods: ['afternoon', 'night'] },
  { text: '深呼吸，今天的空气和昨天不一样。', author: '佚名', periods: ['morning'] },
  { text: '你是一本书，每天翻开新的一页。', author: '佚名', periods: ['morning'] },
  { text: '浮云一别后，流水十年间。', author: '韦应物', periods: ['afternoon', 'night'] },
  { text: '山中何事？松花酿酒，春水煎茶。', author: '张可久', periods: ['morning', 'noon'] },
  { text: '宠辱不惊，看庭前花开花落。', author: '洪应明', periods: ['noon', 'afternoon'] },
  { text: '此心安处是吾乡。', author: '苏轼', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '人生如逆旅，我亦是行人。', author: '苏轼', periods: ['afternoon', 'night'] },
  { text: '愿我如星君如月，夜夜流光相皎洁。', author: '范成大', periods: ['night'] },
  { text: '行到水穷处，坐看云起时。', author: '王维', periods: ['noon', 'afternoon'] },
  { text: '晚来天欲雪，能饮一杯无？', author: '白居易', periods: ['night'] },
  { text: '当时明月在，曾照彩云归。', author: '晏几道', periods: ['night'] },
  { text: '春风得意马蹄疾，一日看尽长安花。', author: '孟郊', periods: ['morning'] },
  { text: '云想衣裳花想容，春风拂槛露华浓。', author: '李白', periods: ['morning', 'noon'] },
  { text: '竹杖芒鞋轻胜马，谁怕？一蓑烟雨任平生。', author: '苏轼', periods: ['morning', 'afternoon'] },
  { text: '醉后不知天在水，满船清梦压星河。', author: '唐温如', periods: ['night'] },
  { text: '桃李春风一杯酒，江湖夜雨十年灯。', author: '黄庭坚', periods: ['night'] },
  { text: '天空没有翅膀的痕迹，但我已飞过。', author: '泰戈尔', periods: ['morning', 'noon', 'afternoon'] },
  { text: '世界以痛吻我，要我报之以歌。', author: '泰戈尔', periods: ['afternoon', 'night'] },
  { text: '不要因为走得太远，忘了为什么出发。', author: '纪伯伦', periods: ['afternoon', 'night'] },
  { text: '你是你，已是最好的你。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '潮落之后一定有潮起，没什么了不起。', author: '五月天', periods: ['afternoon', 'night'] },
  { text: '这世界偷偷爱着你，只是你不知道而已。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '万物静默如谜，而你是我唯一的答案。', author: '佚名', periods: ['night'] },
  { text: '风会记住每一朵花的香。', author: '佚名', periods: ['morning', 'afternoon'] },
  { text: '与其仰望星空，不如做一颗会发光的星。', author: '佚名', periods: ['morning', 'night'] },
  { text: '生活的底色是温柔。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '慢慢来，比较快。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '不必借光而行，你我亦是星辰。', author: '佚名', periods: ['night', 'morning'] },
  { text: '南风知我意，吹梦到西洲。', author: '佚名', periods: ['night'] },
  { text: '我见众生皆草木，唯有见你是青山。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '日落尤其温柔，人间皆是浪漫。', author: '佚名', periods: ['afternoon', 'night'] },
  { text: '且将新火试新茶，诗酒趁年华。', author: '苏轼', periods: ['morning', 'noon'] },
  { text: '山川异域，风月同天。', author: '长屋王', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '眼中有星辰，心中有山海。', author: '佚名', periods: ['morning', 'noon', 'afternoon', 'night'] },
  { text: '爱自己是终身浪漫的开始。', author: '王尔德', periods: ['morning', 'noon', 'afternoon', 'night'] },
];
