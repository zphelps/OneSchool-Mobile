import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/configuration.dart';

import '../../../services/fb_database.dart';

class Moderation extends StatefulWidget {
  final TenantModel tenantModel;
  final AppConfiguration prefs;
  const Moderation({Key? key, required this.tenantModel, required this.prefs}) : super(key: key);

  @override
  State<Moderation> createState() => _ModerationState();
}

class _ModerationState extends State<Moderation> {

  late bool enableModeration;
  late bool blockModerationContent;

  @override
  void initState() {
    super.initState();
    enableModeration = widget.tenantModel.enableModeration;
    blockModerationContent = widget.tenantModel.blockModeratedContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Moderation Preferences',
          style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 17
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Moderation',
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'By leveraging advanced AI algorithms, our moderation engine can catch offensive/inappropriate content before it is shared.',
                      style: GoogleFonts.inter(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _tile(
                    'Enabled Moderation',
                    enableModeration,
                    (value) async {
                      setState(() {
                        enableModeration = value;
                      });
                      if(!enableModeration) {
                        await FBDatabase.updateTenantConfiguration('enableModeration', value);
                        setState(() {
                          blockModerationContent = false;
                        });
                        await FBDatabase.updateTenantConfiguration('blockModerationContent', false);
                      }
                      else {
                        await FBDatabase.updateTenantConfiguration('enableModeration', value);
                      }
                    },
                  ),
                  if(enableModeration)
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _tile(
                        'Block content flagged by the moderation engine. If disabled, users will be warned but may still share anyway.',
                        blockModerationContent,
                            (value) async {
                          setState(() {
                            blockModerationContent = value;
                          });
                          await FBDatabase.updateTenantConfiguration('blockModerationContent', value);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, bool selection, void Function(bool) onChanged) {
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16
        ),
      ),
      trailing: CupertinoSwitch(
        activeColor: widget.prefs.getPrimaryColor(),
        value: selection,
        onChanged: onChanged,
      ),
    );
  }
}
