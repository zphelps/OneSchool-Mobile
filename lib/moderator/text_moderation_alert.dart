import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/moderator/moderator.dart';
import 'package:sea/services/configuration.dart';

import '../zap_widgets/zap_button.dart';

class TextModerationAlert extends StatefulWidget {
  final TextModeratorResponse moderatorResponse;
  final String proceedAnywayLabel;
  final void Function() proceedAnywayAction;
  const TextModerationAlert({Key? key, required this.moderatorResponse, required this.proceedAnywayAction, required this.proceedAnywayLabel}) : super(key: key);

  @override
  State<TextModerationAlert> createState() => _TextModerationAlertState();
}

class _TextModerationAlertState extends State<TextModerationAlert> {

  getOffensiveTermsString() {
    String toReturn = '';
    if(widget.moderatorResponse.terms.isNotEmpty) {
      for(int i = 0; i < widget.moderatorResponse.terms.length; i++) {
        if(widget.moderatorResponse.terms.length == 1) {
          toReturn += '"${widget.moderatorResponse.terms[i]}"';
        }
        else if(i == widget.moderatorResponse.terms.length-1) {
          toReturn += 'and "${widget.moderatorResponse.terms[i]}"';
        }
        else {
          toReturn += '"${widget.moderatorResponse.terms[i]}", ';
        }
      }
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 125,
              ),
              const SizedBox(height: 15),
              Text(
                'Oh no! It appears that you may be trying to share something inappropriate',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 25),
              if(getOffensiveTermsString().isNotEmpty)
                Text(
                  'Words and phrases such as ${getOffensiveTermsString()} are potentially offensive.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    height: 1.4,
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const Spacer(),
              Text(
                'Advanced AI algorithms are used to detect inappropriate content, '
                    'but sometimes they make a mistake. If you believe that this is a mistake, '
                    'you can go ahead and post this content.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 15),
              ZAPButton(
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 2),
                child: Text(
                  'Modify',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ZAPButton(
                onPressed: widget.proceedAnywayAction,
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
                child: Text(
                  widget.proceedAnywayLabel,
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
