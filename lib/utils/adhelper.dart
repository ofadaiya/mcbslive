import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';

class AdHelper {
  static SharedPref sharePref = SharedPref();

  static bool? isPremiumBuy;

  static String? banneradid;
  static String? banneradidios;
  static String? interstitaladid;
  static String? interstitaladidios;
  static String? rewardadid;
  static String? rewardadidios;

  static int? _numInterstitialLoadAttempts = 0;
  static int? maxInterstitialAdclick = 0;
  static int? maxInterstitialAdIOSclick = 0;

  static int? _numRewardAttempts = 0;
  static int? maxRewardAdclick = 0;
  static int? maxRewardAdIOSclick = 0;

  static var bannerad = "";
  static var banneradIos = "";
  static var interstitalad = "";
  static var interstitalIos = "";
  static var rewardad = "";
  static var rewardadIos = "";

  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;

  static AdRequest request = AdRequest(
    keywords: <String>[Constant.appName, 'Flutter App'],
    contentUrl: 'https://flutter.io',
    nonPersonalizedAds: true,
  );

  Future<InitializationStatus> initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  static getAds(BuildContext context) async {
    isPremiumBuy = await Utils.checkPremiumUser();
    bannerad = await sharePref.read("banner_ad") ?? "";
    banneradIos = await sharePref.read("ios_banner_ad") ?? "";
    banneradid = await sharePref.read("banner_adid") ?? "";
    banneradidios = await sharePref.read("ios_banner_adid") ?? "";

    interstitalad = await sharePref.read("interstital_ad") ?? "";
    interstitalIos = await sharePref.read("ios_interstital_ad") ?? "";
    interstitaladid = await sharePref.read("interstital_adid") ?? "";
    interstitaladidios = await sharePref.read("ios_interstital_adid") ?? "";

    rewardad = await sharePref.read("reward_ad") ?? "";
    rewardadIos = await sharePref.read("ios_reward_ad") ?? "";
    rewardadid = await sharePref.read("reward_adid") ?? "";
    rewardadidios = await sharePref.read("ios_reward_adid") ?? "";
    String interstialAdClick =
        await sharePref.read("interstital_adclick") ?? "";
    String rewardAdClick = await sharePref.read("reward_adclick") ?? "";
    String interstialAdIOSClick =
        await sharePref.read("ios_interstital_adclick") ?? "";
    String rewardAdIOSClick = await sharePref.read("ios_reward_adclick") ?? "";

    if (interstialAdIOSClick != "") {
      maxInterstitialAdIOSclick = int.parse(interstialAdIOSClick);
    }
    if (rewardAdIOSClick != "") {
      maxRewardAdIOSclick = int.parse(rewardAdIOSClick);
    }
    if (interstialAdClick != "") {
      maxInterstitialAdclick = int.parse(interstialAdClick);
    }
    if (rewardAdClick != "") {
      maxRewardAdclick = int.parse(rewardAdClick);
    }

    printLog("========================================");
    printLog("isPremiumBuy   : $isPremiumBuy");
    printLog("banner         : $bannerad");
    printLog("banneradIos    : $banneradIos");
    printLog("interstital    : $interstitalad");
    printLog("interstitalIos : $interstitalIos");
    printLog("reward         : $rewardad");
    printLog("rewardadIos    : $rewardadIos");
    printLog("========================================");
    printLog("maxInterstitialAdclick    : $maxInterstitialAdclick");
    printLog("maxRewardAdclick          : $maxRewardAdclick");
    printLog("maxInterstitialAdIOSclick : $maxInterstitialAdIOSclick");
    printLog("maxRewardAdIOSclick       : $maxRewardAdIOSclick");
    printLog("========================================");

    if (!kIsWeb && !(isPremiumBuy ?? false)) {
      AdHelper.createInterstitialAd();
      AdHelper.createRewardedAd();
    }
  }

  // Banner Ad
  static Widget bannerAd(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        if (bannerad == "1") {
          if (bannerAdUnitId != "null" || bannerAdUnitId.isNotEmpty) {
            if (!(isPremiumBuy ?? false)) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: AdSize.banner.height.toDouble(),
                  child: AdWidget(
                    ad: createBannerAd()..load(),
                    key: UniqueKey(),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      } else if (Platform.isIOS) {
        if (banneradIos == "1") {
          if (bannerAdUnitId != "null" || bannerAdUnitId.isNotEmpty) {
            if (!(isPremiumBuy ?? false)) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: AdSize.banner.height.toDouble(),
                  child: AdWidget(
                    ad: createBannerAd()..load(),
                    key: UniqueKey(),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  static BannerAd createBannerAd() {
    BannerAd? bannerAd;
    printLog(
        '================ bannerAdUnitId : $bannerAdUnitId ================');
    bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => printLog('BannerAd Loaded'),
        onAdClosed: (Ad ad) => printLog('BannerAd Closed'),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) => printLog('BannerAd Open'),
      ),
    );
    return bannerAd;
  }

  // Interstial Ad
  static void createInterstitialAd() {
    printLog(
        '================ createInterstitialAd : $interstitialAdUnitId ================');
    if ((interstitalad == "1" && Platform.isAndroid) ||
        (interstitalIos == "1" && Platform.isIOS)) {
      if (interstitialAdUnitId != "null" || interstitialAdUnitId.isNotEmpty) {
        InterstitialAd.load(
          adUnitId: interstitialAdUnitId,
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              printLog('createInterstitialAd ====> $ad');
              _interstitialAd = ad;
              _numInterstitialLoadAttempts = 0;
              ad.setImmersiveMode(true);
            },
            onAdFailedToLoad: (LoadAdError error) {
              if (Platform.isAndroid) {
                if ((_numInterstitialLoadAttempts ?? 0) <=
                    (maxInterstitialAdclick ?? 0)) {
                  createInterstitialAd();
                }
              } else {
                if ((_numInterstitialLoadAttempts ?? 0) <=
                    (maxInterstitialAdIOSclick ?? 0)) {
                  createInterstitialAd();
                }
              }
            },
          ),
        );
      }
    }
  }

  static interstitialAd(BuildContext context, VoidCallback callAction) {
    if ((interstitalad == "1" && Platform.isAndroid) ||
        (interstitalIos == "1" && Platform.isIOS)) {
      showInterstitialAd(callAction);
    } else {
      printLog("action Device");
      callAction();
    }
  }

  static showInterstitialAd(VoidCallback callAction) {
    printLog(
        '_numInterstitialLoadAttempts ====> $_numInterstitialLoadAttempts');
    printLog('maxInterstitialAdclick ==========> $maxInterstitialAdclick');
    printLog('maxInterstitialAdIOSclick =======> $maxInterstitialAdIOSclick');
    if (_interstitialAd == null) {
      printLog('Warning: attempt to show interstitial before loaded.');
      callAction();
      return;
    }
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        printLog('ad onAdShowedFullScreenContent.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        _numInterstitialLoadAttempts = 0;
        printLog('$ad onAdDismissedFullScreenContent.');
        callAction();
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        printLog('$ad onAdFailedToShowFullScreenContent: $error');
        callAction();
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd?.show();
    _interstitialAd = null;
    return;
  }

  // Reward Ad
  static createRewardedAd() {
    printLog(
        '================ createRewardedAd : $rewardedAdUnitId ================');
    if ((rewardad == "1" && Platform.isAndroid) ||
        (rewardadIos == "1" && Platform.isIOS)) {
      if (rewardedAdUnitId != "null" || rewardedAdUnitId.isNotEmpty) {
        RewardedAd.load(
          adUnitId: rewardedAdUnitId,
          request: const AdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (RewardedAd ad) {
              printLog('$ad loaded.');
              _rewardedAd = ad;
              _numRewardAttempts = 0;
            },
            onAdFailedToLoad: (LoadAdError error) {
              _rewardedAd = null;
              _numRewardAttempts = (_numRewardAttempts ?? 0) + 1;
              if (Platform.isAndroid) {
                if ((_numRewardAttempts ?? 0) <= (maxRewardAdclick ?? 0)) {
                  createRewardedAd();
                }
              } else {
                if ((_numRewardAttempts ?? 0) <= (maxRewardAdIOSclick ?? 0)) {
                  createRewardedAd();
                }
              }
            },
          ),
        );
      }
    }
  }

  static rewardedAd(BuildContext context, VoidCallback callAction) {
    if ((rewardad == "1" && Platform.isAndroid) ||
        (rewardadIos == "1" && Platform.isIOS)) {
      printLog("rewardedAd add");
      showRewardedAd(callAction);
    } else {
      printLog("rewardedAd action Device");
      callAction();
    }
  }

  static showRewardedAd(VoidCallback callAction) {
    printLog('_numRewardAttempts =====> $_numRewardAttempts');
    printLog('maxRewardAdclick =======> $maxRewardAdclick');
    printLog('maxRewardAdIOSclick ====> $maxRewardAdIOSclick');
    if (_rewardedAd == null) {
      printLog('Warning: attempt to show rewarded before loaded.');
      callAction();
      return;
    }
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          printLog('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _numRewardAttempts = 0;
        printLog('$ad onAdDismissedFullScreenContent.');
        callAction();
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        printLog('$ad onAdFailedToShowFullScreenContent: $error');
        callAction();
        ad.dispose();
        createRewardedAd();
      },
    );

    _rewardedAd?.setImmersiveMode(true);
    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      printLog('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }

  // Show Fullscreen Ad Function
  static showFullscreenAd(
      BuildContext context, String adType, VoidCallback callAction) async {
    bool? isBuy = await Utils.checkPremiumUser();
    printLog("showFullscreenAd isBuy ============> $isBuy");
    if (isBuy) {
      callAction();
      return;
    }
    if (!kIsWeb) {
      if (adType == Constant.rewardAdType) {
        if (((rewardad == "1" && Platform.isAndroid) ||
                (rewardadIos == "1" && Platform.isIOS)) &&
            checkRewardAdAndShow()) {
          printLog("rewardedAd add");
          showRewardedAd(callAction);
        } else {
          printLog("rewardedAd action Device");
          callAction();
        }
      } else if (adType == Constant.interstialAdType) {
        if (((interstitalad == "1" && Platform.isAndroid) ||
                (interstitalIos == "1" && Platform.isIOS)) &&
            checkInterstialAdAndShow()) {
          showInterstitialAd(callAction);
        } else {
          printLog("rewardedAd action Device");
          callAction();
        }
      } else {
        if (((rewardad == "1" && Platform.isAndroid) ||
                (rewardadIos == "1" && Platform.isIOS)) &&
            checkRewardAdAndShow()) {
          printLog("rewardedAd add");
          showRewardedAd(callAction);
        } else if (((interstitalad == "1" && Platform.isAndroid) ||
                (interstitalIos == "1" && Platform.isIOS)) &&
            checkInterstialAdAndShow()) {
          showInterstitialAd(callAction);
        } else {
          printLog("rewardedAd action Device");
          callAction();
        }
      }
    } else {
      printLog("rewardedAd action Device");
      callAction();
    }
  }

  static bool checkInterstialAdAndShow() {
    printLog("loadAttempts ================> $_numInterstitialLoadAttempts");
    printLog("maxInterstitialAdclick ======> $maxInterstitialAdclick");
    printLog("maxInterstitialAdIOSclick ===> $maxInterstitialAdIOSclick");
    if (!kIsWeb) {
      if (Platform.isIOS) {
        if ((_numInterstitialLoadAttempts ?? 0) >=
            (maxInterstitialAdIOSclick ?? 0)) {
          return true;
        } else {
          _numInterstitialLoadAttempts =
              (_numInterstitialLoadAttempts ?? 0) + 1;
          return false;
        }
      } else {
        if ((_numInterstitialLoadAttempts ?? 0) >=
            (maxInterstitialAdclick ?? 0)) {
          return true;
        } else {
          _numInterstitialLoadAttempts =
              (_numInterstitialLoadAttempts ?? 0) + 1;
          return false;
        }
      }
    }
    return false;
  }

  static bool checkRewardAdAndShow() {
    printLog("loadAttempts =============> $_numRewardAttempts");
    printLog("maxRewardAdclick =========> $maxRewardAdclick");
    printLog("maxRewardAdIOSclick ======> $maxRewardAdIOSclick");
    if (!kIsWeb) {
      if (Platform.isIOS) {
        if ((_numRewardAttempts ?? 0) >= (maxRewardAdIOSclick ?? 0)) {
          return true;
        } else {
          _numRewardAttempts = (_numRewardAttempts ?? 0) + 1;
          return false;
        }
      } else {
        if ((_numRewardAttempts ?? 0) >= (maxRewardAdclick ?? 0)) {
          return true;
        } else {
          _numRewardAttempts = (_numRewardAttempts ?? 0) + 1;
          return false;
        }
      }
    }
    return false;
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return banneradid.toString();
    } else if (Platform.isIOS) {
      return banneradidios.toString();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return interstitaladid.toString();
    } else if (Platform.isIOS) {
      return interstitaladidios.toString();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return rewardadid.toString();
    } else if (Platform.isIOS) {
      return rewardadidios.toString();
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
