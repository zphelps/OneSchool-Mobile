import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/PushNotificationSettingsModel.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/fb_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/SEAUser.dart';
import '../../services/configuration.dart';
import '../../services/fb_auth.dart';
import '../../zap_widgets/zap_button.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key, required this.tenant}) : super(key: key);

  final TenantModel tenant;

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {

  final _formKey = GlobalKey<FormState>();
  final _auth = FBAuth();

  String _email = '';
  String _password = '';

  String? errorMessage;

  bool loggingIn = false;

  Future<void> login() async {
    setState(() => loggingIn = true);
    _formKey.currentState!.save();
    if(_formKey.currentState!.validate()){
      dynamic result = await _auth.signInWithEmailAndPassword(tenantID: widget.tenant.tenantID, email: _email, password: _password);
      if(result is String) {
        setState(() {
          errorMessage = result.split('] ').last;
        });
      }
      else {
        FBDatabase.tenantID = widget.tenant.tenantID;
        ///Creating Sample User Data:
        // final user = SEAUser(
        //   id: 'xq23z2rgtBNND4WCcjxYFazL7Z53',
        //   firstName: 'Zach',
        //   lastName: 'Phelps',
        //   email: _email,
        //   phoneNumber: null,
        //   pushNotificationSettings: PushNotificationSettingModel(
        //     allowPushNotifications: true,
        //     newEventFromFollowingGroup: false,
        //     newEventFromMemberGroup: false,
        //     newPostFromFollowingGroup: false,
        //     newPostFromMemberGroup: false,
        //   ),
        //   fcmToken: null,
        //   userRoles: null
        // );
        //
        // await FBDatabase.createUserData(user);

        setState(() => errorMessage = null);
        Navigator.of(context).popUntil((route) => !route.hasActiveRouteBelow);
      }
    }
    setState(() => loggingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Text(
                    'Log into ${widget.tenant.name}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      onSaved: (value) {
                        setState(() => _email = value ?? '');
                      },
                      validator: (value) {
                        if((value ?? '').isEmpty) {
                          return 'Must supply email.';
                        }
                        return null;
                      },
                      autocorrect: false,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Email',
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      autocorrect: false,
                      onSaved: (value) {
                        setState(() => _password = value ?? '');
                      },
                      validator: (value) {
                        if((value ?? '').isEmpty) {
                          return 'Must supply password.';
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: 'Password',
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                        ),
                      ),
                    ),
                  ),
                  if(errorMessage != null)
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  if(errorMessage == null)
                    const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ZAPButton(
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: CupertinoColors.activeBlue,
                      onPressed: () async {
                        await login();
                        final sharedPrefService = ref.watch(sharedPreferencesServiceProvider);

                        sharedPrefService.setPrimaryColor(widget.tenant.primaryColorString);
                        sharedPrefService.setSchoolName(widget.tenant.name);
                        sharedPrefService.setSchoolLogoURL(widget.tenant.logoURL);
                        sharedPrefService.setTenantID(widget.tenant.tenantID);
                      },
                      child: Text(
                        'Login',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(loggingIn)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: Center(
                    child: PlatformCircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
