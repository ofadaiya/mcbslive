import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'music/musicdetails.dart';
import 'provider/addfavouriteprovider.dart';
import 'provider/liveeventsprovider.dart';
import 'provider/musicdetailprovider.dart';
import 'provider/podcastprovider.dart';
import 'provider/podcastviewallprovider.dart';
import 'provider/searchprovider.dart';
import 'provider/themeprovider.dart';
import 'provider/viewallprovider.dart';
import 'provider/generalprovider.dart';
import 'pages/splash.dart';
import 'provider/radiobyidprovider.dart';
import 'provider/homeprovider.dart';
import 'provider/languageprovider.dart';
import 'provider/notificationprovider.dart';
import 'provider/paymentprovider.dart';
import 'provider/profileprovider.dart';
import 'provider/subhistoryprovider.dart';
import 'provider/subscriptionprovider.dart';
import 'provider/updateprofileprovider.dart';
import 'utils/color.dart';
import 'utils/constant.dart';
import 'music/musicmanager.dart';
import 'utils/sharedpref.dart';
import 'utils/utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Just Audio Player Background Service Set
  await JustAudioBackground.init(
    androidNotificationChannelId: Constant.appPackageName,
    androidNotificationChannelName: Constant.appName,
    notificationColor: colorPrimary,
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Locales.init([
    'en',
    'ar',
    'hi',
    'fr',
    'gu',
    'pt',
    'af',
    'nl',
    'de',
    'id',
    'es',
    'tr',
    'vi',
    'sq'
  ]);

  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: white,
      statusBarColor: transparent,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).whenComplete(
    () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GeneralProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => UpdateProfileProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
          ChangeNotifierProvider(create: (_) => RadioByIdProvider()),
          ChangeNotifierProvider(create: (_) => AddFavouriteProvider()),
          ChangeNotifierProvider(create: (_) => ViewAllProvider()),
          ChangeNotifierProvider(create: (_) => PaymentProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => SubHistoryProvider()),
          ChangeNotifierProvider(create: (_) => PodcatsProvider()),
          ChangeNotifierProvider(create: (_) => LiveEventProvider()),
          ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
          ChangeNotifierProvider(create: (_) => PodcatViewAllProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPref sharedpre = SharedPref();
  late ThemeProvider themeProvider;
  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (!kIsWeb) Utils.enableScreenCapture();
    if (!kIsWeb) _getPackage();
    musicManager = MusicManager(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkTheme();
    });
  }

  checkTheme() async {
    Constant.userID = await sharedpre.read('userid');
    Constant.isDark = await sharedpre.readBool("isdark") ?? false;
    printLog("isDark==> ${Constant.isDark}");
    themeProvider.changeTheme(Constant.isDark);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        /* Theme Start */
        themeMode: themeProvider.themeMode,
        theme: lightTheme,
        darkTheme: darkTheme,
        /* Theme End */
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        debugShowCheckedModeBanner: false,
        home: const Splash(),
      ),
    );
  }

  _getPackage() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;
    String appVersion = packageInfo.version;
    String appBuildNumber = packageInfo.buildNumber;

    Constant.appPackageName = packageName;
    Constant.appVersion = appVersion;
    Constant.appBuildNumber = appBuildNumber;
    printLog(
        "App Package Name : $packageName, App Version : $appVersion, App build Number : $appBuildNumber");
  }
}
