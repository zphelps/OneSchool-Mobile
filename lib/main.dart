
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Settings;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/screens/Welcome/welcome.dart';
import 'package:sea/screens/email_testing.dart';
import 'package:sea/screens/events/events.dart';
import 'package:sea/screens/feed/feed_query.dart';
import 'package:sea/screens/groups/groups.dart';
import 'package:sea/screens/home/home.dart';
import 'package:sea/screens/media_gallery/media_gallery.dart';
import 'package:sea/screens/messaging/conversation_view.dart';
import 'package:sea/screens/messaging/conversations.dart';
import 'package:sea/screens/notifications/notifications.dart';
import 'package:sea/screens/settings/settings.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';
import 'package:sea/services/fb_database.dart';
import 'package:sea/services/fb_messaging.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import 'package:sea/widgets/auth_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/ConversationModel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// Obtain shared preferences.
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesServiceProvider.overrideWithValue(
        AppConfiguration(prefs),
      ),
    ],
    child: const Main(),
  ));
}

class Main extends ConsumerStatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  ConsumerState<Main> createState() => _MainState();
}

class _MainState extends ConsumerState<Main> with AutomaticKeepAliveClientMixin {

  late StreamSubscription tokenStream;

  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;

  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey(debugLabel: 'Main Navigator');

  final PageController _controller = PageController(initialPage: 0, keepPage: true);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.jumpToPage(_selectedIndex);
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    print('Beginning initializeFlutterFire...');
    try {

      if(FBAuth().getUserID() == null) {
        print('sign out');
        await FBAuth().signOut();
      }
      else {
        FBDatabase.tenantID = FBAuth().getTenantID();
        if(FBDatabase.tenantID != null) {
          final tenant = await FBDatabase.getTenant();
          final sharedPrefService = ref.watch(sharedPreferencesServiceProvider);

          await sharedPrefService.setPrimaryColor(tenant.primaryColorString);
          await sharedPrefService.setSchoolName(tenant.name);
          await sharedPrefService.setSchoolLogoURL(tenant.logoURL);
          await sharedPrefService.setTenantID(tenant.tenantID);
        }
      }

      NotificationSettings settings = await FBMessaging.firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleNotification(initialMessage.data, navigatorKey);
      }
      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage? remoteMessage) {
        if (remoteMessage != null) {
          _handleNotification(remoteMessage.data, navigatorKey);
        }
      });
      if (!Platform.isIOS) {
        FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
      }

      final token = await FBMessaging.firebaseMessaging.getToken();

      print(token);
      print(FBDatabase.tenantID);

      if(token != null && FBAuth().getUserID() != null && FBAuth().getTenantID() != null) {
        print('token updated');
        FBDatabase.updateUserFCMToken(FBAuth().getUserID()!, token);
      }

      tokenStream = FBMessaging.firebaseMessaging.onTokenRefresh.listen((event) {
            print('Event:');
            print('token $event');
            if(FBAuth().getUserID() != null && FBAuth().getTenantID() != null) {
              FBDatabase.updateUserFCMToken(FBAuth().getUserID()!, event);
            }
          });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      print('fail');
      print(e.toString());
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {

    final prefs = ref.watch(sharedPreferencesServiceProvider);
    // Show error message if initialization failed
    if (_error) {
      return Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
              child: Column(
                children: const [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 25,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to initialise firebase!',
                    style: TextStyle(color: Colors.red, fontSize: 25),
                  ),
                ],
              )),
        ),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            color: Colors.white,
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(primaryColor: prefs.getPrimaryColor()),
      home: AuthWidget(
        signedInBuilder: (_) {
          final userAsyncValue = ref.watch(getUserStreamProvider(FBAuth().getUserID()!));
          return userAsyncValue.when(
            data: (user) {
              if(FBAuth().getTenantID() == null) {
                return const Text('Tenant ID is null');
              }
              final tenantAsyncValue = ref.watch(tenantStreamProvider(FBAuth().getTenantID()!));
              return tenantAsyncValue.when(
                data: (tenant) {
                  return Scaffold(
                    body: PageView(controller: _controller, physics: const NeverScrollableScrollPhysics(), children: [
                      Home(prefs: prefs, tenantModel: tenant, user: user),
                      Events(user: user),
                      Groups(user: user),
                      const Conversations(),
                      Settings(user: user, prefs: prefs, tenantModel: tenant),
                    ]),
                    bottomNavigationBar: BottomNavigationBar(
                      type: BottomNavigationBarType.shifting,
                      selectedLabelStyle: TextStyle(color: prefs.getPrimaryColor(), fontWeight: FontWeight.w400, fontSize: 12),
                      elevation: 0,
                      showUnselectedLabels: false,
                      backgroundColor: Colors.grey.shade50.withOpacity(0.5),
                      items: const <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.event),
                          label: 'Events',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.group),
                          label: 'Groups',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.message_outlined),
                          label: 'Conversations',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.settings),
                          label: 'Settings',
                        ),
                      ],
                      currentIndex: _selectedIndex,
                      unselectedItemColor: Colors.grey,
                      selectedItemColor: prefs.getPrimaryColor(),
                      onTap: _onItemTapped,
                    ),
                  );
                },
                loading: () => const Scaffold(backgroundColor: Colors.white, body: Center(child: CupertinoActivityIndicator())),
                error: (e,stack) => Scaffold(body: Center(child: Text('${FBAuth().getUserID()!} ${e.toString()}'))),
              );
            },
            loading: () => const Scaffold(backgroundColor: Colors.white, body: Center(child: CupertinoActivityIndicator())),
            error: (e,stack) => Scaffold(body: Center(child: Text('${FBAuth().getUserID()!} ${e.toString()}'))),
          );
        },
        nonSignedInBuilder: (_) => const Welcome()
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// this faction is called when the notification is clicked from system tray
/// when the app is in the background or completely killed
void _handleNotification(
    Map<String, dynamic> message, GlobalKey<NavigatorState> navigatorKey) {
  /// right now we only handle click actions on chat messages only
  try {
    if (message.containsKey('members') && message.containsKey('isGroup') && message.containsKey('conversationModel')) {
      final conversationModel = ConversationModel.fromMap(jsonDecode(message['conversationModel']),'hi');
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ConversationView(
            conversationModel: conversationModel,
          ),
        ),
      );
    }
    else if (message.containsKey('notificationID')) {
      print(message['notificationID']);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => Notifications(notificationID: message['notificationID']),
        ),
      );
    }
  } catch (e, s) {
    print('MyAppState._handleNotification $e $s');
  }
}

Future<dynamic> backgroundMessageHandler(RemoteMessage remoteMessage) async {
  // await Firebase.initializeApp();
  Map<dynamic, dynamic> message = remoteMessage.data;
  print('backgroundMessageHandler $message');

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }
}