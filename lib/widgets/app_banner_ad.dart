import 'dart:io';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  String get _adUnitId {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-3875855492720539/6462236686'; // Real ad unit ID
      } else {
        return 'ca-app-pub-3940256099942544/6300978111';// Test ad unit for development
      }
    } else if (Platform.isIOS) {
      if (kReleaseMode) {
        return 'ca-app-pub-3875855492720539/6462236686'; // iOS real ad unit ID (same as Android if not specified separately)
      } else {
        return 'ca-app-pub-3940256099942544/6300978111'; // Test ad unit for iOS
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoaded && _bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    print('Loading banner ad with ID: $_adUnitId');
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        // onAdFailedToLoad: (ad, error) {
        //   print('Banner ad failed to load: $error');
        //   ad.dispose();
        //   if (mounted) {
        //     setState(() {
        //       _bannerAd = null;
        //       _isLoaded = false;
        //     });
        //   }
        // },
        onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null;
        _isLoaded = false;

        Future.delayed(Duration(seconds: 10), () {
          if (mounted) _loadAd();
        });
      },
        onAdOpened: (ad) => print('Banner ad opened'),
        onAdClosed: (ad) => print('Banner ad closed'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      bottom: true,
      left: false,
      right: false,
      top: false,
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
