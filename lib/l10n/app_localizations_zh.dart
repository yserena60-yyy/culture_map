// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get newStampUnlocked => '🏆 获得新印章！';

  @override
  String get gpsRequired => '请先开启GPS定位以获取探索印章。';

  @override
  String get tooFarFromLandmark => '需在地标500米范围内才能获得印章。';

  @override
  String get colosseumName => '罗马斗兽场';

  @override
  String get pyramidName => '塞斯提伍斯金字塔';

  @override
  String get pantheonName => '罗马万神殿';

  @override
  String get feedEmpty => '全球知识库同步中...\n或点击 + 贡献一个地点。';

  @override
  String formatYearIntAD(int y) {
    return '公元 $y 年';
  }

  @override
  String formatYearIntBC(int y) {
    return '公元前 $y 年';
  }

  @override
  String get exploreRoutes => '探索历史叙事路线';

  @override
  String get exploreRoutesSub => '跟随时间足迹，开启空间叙事探索之旅。';

  @override
  String get featuredRoutes => '官方推荐路线';

  @override
  String get communityRoutes => '云端众包路线';

  @override
  String get createRoute => '设计并发布众包路线';

  @override
  String get createRouteSub => '在地图上打点、串联历史古迹，分享你的历史探秘线索';

  @override
  String stopsCount(int n) {
    return '$n个站点';
  }

  @override
  String get routeCreatorTitle => '众包路线编辑器';

  @override
  String get routeCreatorHint => '请在地图上点击以添加路线步骤，支持点击多次连线。';

  @override
  String get waypointCountLabel => '节点数';

  @override
  String get cancel => '取消';

  @override
  String get nextPublish => '下一步并发布';

  @override
  String stopLabel(int n) {
    return '第 $n 站：';
  }

  @override
  String progressLabel(int cur, int total) {
    return '进度：$cur / $total';
  }

  @override
  String get prevStepLabel => '上一步';

  @override
  String get nextStepLabel => '下一步';

  @override
  String get addWaypointTitle => '添加路线节点';

  @override
  String get waypointNameHint => '节点名称 (e.g. 雅典卫城)';

  @override
  String get waypointDescHint => '历史描述 / 故事';

  @override
  String get waypointNameRequired => '节点名称不能为空';

  @override
  String get add => '添加';

  @override
  String get publishRouteTitle => '发布众包路线';

  @override
  String get routeNameHint => '路线名称 (e.g. 丝绸之路)';

  @override
  String get routeDescHint => '路线简介';

  @override
  String get chooseColor => '选择路线颜色:';

  @override
  String get routeNameRequired => '路线名称不能为空';

  @override
  String get back => '返回';

  @override
  String get publishToCloud => '发布至云端';

  @override
  String get publishSuccess => '🎉 众包路线已成功发布到云端！';

  @override
  String publishFail(String e) {
    return '发布失败: $e';
  }

  @override
  String get passportTitle => '文化时空护照';

  @override
  String get passportSubtitle => 'PASSPORT OF TIME & CULTURE';

  @override
  String get stampsCollected => '已收集印章';

  @override
  String get navTurnLeft => '向左转';

  @override
  String get navTurnRight => '向右转';

  @override
  String get navSlightLeft => '稍微左转';

  @override
  String get navSlightRight => '稍微右转';

  @override
  String get navSharpLeft => '急左转';

  @override
  String get navSharpRight => '急右转';

  @override
  String get navStart => '出发';

  @override
  String get navArrive => '到达目的地';

  @override
  String get navContinue => '继续直行';

  @override
  String get navRoundabout => '进入环岛';

  @override
  String get navRotary => '进入转盘';

  @override
  String get navMerge => '并道';

  @override
  String get navFork => '走岔路';

  @override
  String get navContinueForward => '继续前进';

  @override
  String get navWalking => '步行';

  @override
  String get navCycling => '骑行';

  @override
  String get navDriving => '驾车';

  @override
  String navStarting(String mode, String dest, String dist, String time) {
    return '开始$mode导航，前往$dest，全程$dist，预计$time';
  }

  @override
  String navArrived(String dest) {
    return '您已到达目的地，$dest';
  }

  @override
  String navInMeters(int meters, String instruction) {
    return '前方$meters米，$instruction';
  }

  @override
  String navDistance(String instruction, String dist) {
    return '$instruction，距离$dist';
  }

  @override
  String get navVoiceEnabled => '语音播报已开启';

  @override
  String navSwitchedMode(String mode) {
    return '已切换到$mode模式';
  }

  @override
  String get navRemaining => '剩余';

  @override
  String get navEstimatedTime => '预计时间';

  @override
  String get eraRange => '探索年代';

  @override
  String get collectedStampsSection => '时空探索印章';

  @override
  String get colosseumLabel => '罗马斗兽场';

  @override
  String get pyramidLabel => '塞金字塔';

  @override
  String get pantheonLabel => '万神殿';

  @override
  String get letterFromPast => '时空来信 (Letter from the Past)';

  @override
  String get chronicler => '记载者';

  @override
  String get profileTitle => '个人中心';

  @override
  String get loginRegister => '登录 / 注册';

  @override
  String get logout => '退出登录';

  @override
  String get guestExplorer => '探索家游客';

  @override
  String get exploreTab => '探索';

  @override
  String get mapTab => '地图';

  @override
  String get meTab => '我的';

  @override
  String get communityLedger => '社区贡献档案库';

  @override
  String get savedPlaces => '我的收藏';

  @override
  String get systemSettings => '系统设置';

  @override
  String get switchLanguage => '切换语言';

  @override
  String get mapTheme => '地图主题';

  @override
  String get explorerSignIn => '探索家登录';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get newExplorer => '新人？创建账号';

  @override
  String get createAccount => '注册账号';

  @override
  String get existingExplorer => '已有账号？直接登录';

  @override
  String get myDrafts => '我的动态与贡献';

  @override
  String get savedPlacesRoutes => '我的收藏地点与路线';

  @override
  String get editProfile => '编辑资料';

  @override
  String get settings => '设置';

  @override
  String get searchArea => '搜索区域';

  @override
  String get recentComments => '最近评论';

  @override
  String get viewAllComments => '查看全部评论';

  @override
  String get allComments => '全部评论';

  @override
  String get comments => '条评论';

  @override
  String get removeBookmark => '移除收藏';

  @override
  String get removeBookmarkConfirm => '确定要从收藏中移除这个地点吗？';

  @override
  String get remove => '移除';

  @override
  String get unknownPlace => '未知地点';

  @override
  String get noContributions => '暂无贡献记录';

  @override
  String get noSavedPlaces => '暂无收藏地点';

  @override
  String get name => '昵称';

  @override
  String get bio => '个人简介';

  @override
  String get changeAvatar => '更换头像';

  @override
  String get save => '保存';

  @override
  String get level => '等级';

  @override
  String get noviceExplorer => '初级探索家';

  @override
  String get apprenticeExplorer => '学徒探索家';

  @override
  String get journeymanExplorer => '熟练探索家';

  @override
  String get expertExplorer => '专家探索家';

  @override
  String get masterExplorer => '大师探索家';

  @override
  String get legendaryChronicler => '传奇记载者';

  @override
  String get rateExperience => '评价您的体验';

  @override
  String get rating => '评分';

  @override
  String get writeComment => '写下您的评论（可选）';

  @override
  String get submit => '提交';

  @override
  String get ratingSubmitted => '评价提交成功！';

  @override
  String get ratingFailed => '评价提交失败';

  @override
  String get close => '关闭';
}
