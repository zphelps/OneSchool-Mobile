import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/utils/unfocuser.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/fb_auth.dart';

class EditUserPassword extends StatefulWidget {
  final AppConfiguration prefs;
  const EditUserPassword({Key? key, required this.prefs}) : super(key: key);

  @override
  State<EditUserPassword> createState() => _EditUserPasswordState();
}

class _EditUserPasswordState extends State<EditUserPassword> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool loading = false;

  validate() {
    if((_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty && _oldPasswordController.text != _newPasswordController.text)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Change Password',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
        actions: [
          loading ? const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CupertinoActivityIndicator(),
          ) : PlatformTextButton(
            onPressed: () async {
              if(validate()) {
                setState(() {
                  loading = true;
                });
                // final result = await FBAuth().updatePassword(_oldPasswordController.text, _newPasswordController.text);
                // print(phone.phoneNumber!.substring(1));
                // await FBDatabase.updateUserPhoneNumber(widget.user.id, int.parse(phone.phoneNumber!.substring(1)));
                setState(() {
                  loading = false;
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                  color: validate() ? widget.prefs.getPrimaryColor() : Colors.grey[300],
                  fontSize: 17,
                  fontWeight: FontWeight.w600
              ),
            ),
          )
        ],
      ),
      body: Unfocuser(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Old Password',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 18
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                obscureText: true,
                controller: _oldPasswordController,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Old password',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Old Password',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 18
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                obscureText: true,
                controller: _newPasswordController,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'New password',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
