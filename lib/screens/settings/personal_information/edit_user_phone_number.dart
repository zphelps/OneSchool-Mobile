import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/configuration.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../../services/fb_database.dart';
import '../../../widgets/masked_text_controller.dart';

class EditUserPhoneNumber extends StatefulWidget {
  final SEAUser user;
  final AppConfiguration prefs;
  const EditUserPhoneNumber({Key? key, required this.user, required this.prefs}) : super(key: key);

  @override
  State<EditUserPhoneNumber> createState() => _EditUserPhoneNumberState();
}

class _EditUserPhoneNumberState extends State<EditUserPhoneNumber> {
  final _phoneTextController = TextEditingController();

  bool loading = false;

  validate() {
    if((_phoneTextController.text.length == 17 && _phoneTextController.text != '${widget.user.phoneNumber}')) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _phoneTextController.text = '${widget.user.phoneNumber ?? '+1 '}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Edit Phone Number',
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
                final phone = await PhoneNumber.getRegionInfoFromPhoneNumber(_phoneTextController.text);
                print(phone.phoneNumber!.substring(1));
                await FBDatabase.updateUserPhoneNumber(widget.user.id, int.parse(phone.phoneNumber!.substring(1)));
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
                'Phone Number',
                style: GoogleFonts.inter(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 18
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Must include country code. Number will be auto-formatted.',
                style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneTextController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  PhoneInputFormatter()
                ],
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Phone Number',
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
