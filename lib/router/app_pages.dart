import 'package:get/get.dart';
import 'package:trans_flutter/pages/home/view.dart';
import 'package:trans_flutter/pages/setting/view.dart';
import 'package:trans_flutter/pages/setting/pages/provider_manage.dart';
import 'package:trans_flutter/pages/setting/pages/provider_edit.dart';
import 'package:trans_flutter/pages/setting/pages/model_select.dart';
import 'package:trans_flutter/pages/setting/pages/theme_setting.dart';

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/setting', page: () => const SettingPage()),
    GetPage(name: '/providerManage', page: () => const ProviderManagePage()),
    GetPage(name: '/providerEdit', page: () => const ProviderEditPage()),
    GetPage(name: '/modelSelect', page: () => const ModelSelectPage()),
    GetPage(name: '/themeSetting', page: () => const ThemeSettingPage()),
  ];
}
