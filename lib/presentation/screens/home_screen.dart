import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:scamurai/core/app_constants.dart';
import 'package:scamurai/core/app_routes.dart';
import 'package:scamurai/data/services/appwrite_user_service.dart';
import 'package:scamurai/data/services/default_app_settings_service.dart';
import 'package:scamurai/data/services/link_opener_service.dart';
import 'package:scamurai/presentation/widgets/manual_piechart.dart';
import 'package:scamurai/state_management/news_controller.dart';
import 'package:scamurai/state_management/user_controller.dart';
import 'package:scamurai/state_management/tips_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_handler/share_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/quick_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const defaultBrowserChannel =
      MethodChannel(AppConstant.BROWSER_CHANNEL);

  bool _isDefaultBrowser = false;
  StreamSubscription<SharedMedia>? _streamSubscription;
  String? _currentScreen; // Track the current screen
  bool _isNavigating = false; // Track if navigation is in progress
  final NewsController newsController = Get.put(NewsController());
  final TipsController tipsController = Get.put(TipsController());
  int? _expandedIndex; // Track the currently expanded tile index
  Map<String, int> _statistics = {"phishyCount": 0, "notPhishyCount": 0};
  bool _isLoadingStatistics = true;

  @override
  void initState() {
    super.initState();
    _checkIfDefaultBrowser();
    _handleSharedData();
    _fetchStatistics();
  }

  Future<void> _handleSharedData() async {
    final handler = ShareHandlerPlatform.instance;

    // Get initial shared content when app is opened via sharing intent
    SharedMedia? initialMedia = await handler.getInitialSharedMedia();
    if (initialMedia?.content != null) {
      _navigateBasedOnContent(initialMedia!.content!, fromLink: false);
    }

    // Listen for shared content while app is running
    _streamSubscription = handler.sharedMediaStream.listen((SharedMedia media) {
      if (!mounted) return;
      if (media.content != null) {
        _navigateBasedOnContent(media.content!, fromLink: false);
      }
    });
  }

  void _navigateBasedOnContent(String content, {required bool fromLink}) {
    if (_isNavigating) return; // Prevent multiple navigations

    _isNavigating = true;

    if (content.startsWith('http')) {
      if (_currentScreen != AppRoutes.verifyWebsiteScreen) {
        Get.toNamed(AppRoutes.verifyWebsiteScreen, arguments: content)
            ?.then((_) {
          _isNavigating = false;
          _currentScreen = null; // Reset current screen after navigation
        });
        _currentScreen = AppRoutes.verifyWebsiteScreen;
      } else {
        _isNavigating = false;
      }
    } else {
      if (_currentScreen != AppRoutes.scamDetectionScreen) {
        Get.toNamed(AppRoutes.scamDetectionScreen, arguments: content)
            ?.then((_) {
          _isNavigating = false;
          _currentScreen = null; // Reset current screen after navigation
        });
        _currentScreen = AppRoutes.scamDetectionScreen;
      } else {
        _isNavigating = false;
      }
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel(); // Cleanup
    super.dispose();
  }

  /// Checks if the app is set as the default browser
  Future<void> _checkIfDefaultBrowser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool hasPrompted =
          prefs.getBool('hasPromptedDefaultBrowser') ?? false;

      if (!hasPrompted) {
        final bool result =
            await defaultBrowserChannel.invokeMethod("isDefaultBrowser");
        setState(() {
          _isDefaultBrowser = result;
        });

        if (!result) {
          _showDefaultBrowserPrompt();
        }

        // Set the flag to true after showing the prompt
        await prefs.setBool('hasPromptedDefaultBrowser', true);
      }
    } on PlatformException catch (e) {
      print("Failed to check default browser: ${e.message}");
    }
  }

  /// Shows a dialog prompting the user to set this app as the default browser
  void _showDefaultBrowserPrompt() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Set as Default Browser"),
          content: const Text(
              "To enhance the experience, set this app as the default browser."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                DefaultAppSettingsService().openDefaultAppSettings();
              },
              child: const Text("Set Now"),
            ),
          ],
        ),
      );
    });
  }

  void verifyWebsite() {
    Get.toNamed(AppRoutes.verifyWebsiteScreen);
  }

  void reportScam() {
    Get.toNamed(AppRoutes.reportScamScreen);
  }

  void detectScamInText() {
    Get.toNamed(AppRoutes.scamDetectionScreen);
  }

  Future<void> _fetchStatistics() async {
    final userId = Get.find<UserController>().getUser()?.$id;
    if (userId != null) {
      final stats = await AppwriteService().getUserStatistics(userId);
      setState(() {
        _statistics = stats;
        _isLoadingStatistics = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserController _userController = Get.find<UserController>();
    final user = _userController.getUser();
    bool isWeb = MediaQuery.of(context).size.width > 600;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        _userController.fetchUserProfile(user.$id);
      }
    });

    return homeScreen(user, context, isWeb);
  }

  Scaffold homeScreen(User? user, BuildContext context, bool isWeb) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scamurai"),
        actions: [
          IconButton(
              onPressed: () {
                Get.toNamed(AppRoutes.profileScreen);
              },
              icon: const Icon(Icons.person_4_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Text(
                "👋 Welcome Back, ${user?.name ?? 'User'}!",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),

              // Pie Chart Section
              const Text("📊 Scam Statistics"),
              const SizedBox(height: 10),
              _isLoadingStatistics
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ManualPieChart(
                        data: {
                          'Phishy': _statistics["phishyCount"]?.toDouble() ?? 0,
                          'Not Phishy':
                              _statistics["notPhishyCount"]?.toDouble() ?? 0,
                        },
                        colors: [Colors.red, Colors.green],
                      ),
                    ),
              const SizedBox(height: 20),

              // Quick Actions
              const Text("⚡ Quick Actions"),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: isWeb ? 4 : 2,
                childAspectRatio: 1.5,
                children: [
                  QuickActionButton(
                    icon: Icons.report,
                    label: "Report Scam",
                    onClick: reportScam,
                  ),
                  QuickActionButton(
                    icon: Icons.search,
                    label: "Verify Website",
                    onClick: verifyWebsite,
                  ),
                  QuickActionButton(
                    icon: Icons.message,
                    label: "Verify Text",
                    onClick: detectScamInText,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text("📰 Latest Fraud News"),
              const SizedBox(height: 10),

              Obx(() {
                if (newsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (newsController.newsList.isEmpty) {
                  return const Text("No fraud news available at the moment.");
                }

                final topNews = newsController.newsList.take(5).toList();

                return Column(
                  children: [
                    ...topNews.map((article) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: article.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CupertinoActivityIndicator(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        title: Text(article.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(article.source),
                        onTap: () => LinkOpenerService()
                            .openLinkWithBrowserChooser(
                                article.url, AppConstant.OPENING_BROWSER),
                      );
                    }),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.newsListScreen);
                      },
                      child: const Text("See More"),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Learning Hub
              const Text("📚 Fraud Prevention Tips"),
              const SizedBox(height: 10),
              Obx(() {
                if (tipsController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tipsController.tipsList.isEmpty) {
                  return const Text("No fraud prevention tips available.");
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tipsController.tipsList.length,
                  itemBuilder: (context, index) {
                    final tip = tipsController.tipsList[index];
                    return Card(
                      child: ExpansionTile(
                        key: Key(index.toString()), // Unique key for each tile
                        leading: const Icon(Icons.book, color: Colors.blue),
                        title: Text(
                          tip['title'] ??
                              'No Title', // Fallback to 'No Title' if null
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        initiallyExpanded: _expandedIndex == index,
                        onExpansionChanged: (isExpanded) {
                          setState(() {
                            _expandedIndex = isExpanded ? index : null;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              tip['description'] ??
                                  'No Description', // Fallback to 'No Description' if null
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(AppRoutes.chatbotScreen);
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

class ChartData {
  ChartData(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}
