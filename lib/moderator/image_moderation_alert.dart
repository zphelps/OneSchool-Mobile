import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/moderator/moderator.dart';
import 'package:sea/services/configuration.dart';

import '../zap_widgets/zap_button.dart';

class ImageModerationAlert extends StatefulWidget {
  final ImageModeratorResponse moderatorResponse;
  final String proceedAnywayLabel;
  final void Function() proceedAnywayAction;
  const ImageModerationAlert({Key? key, required this.moderatorResponse, required this.proceedAnywayAction, required this.proceedAnywayLabel}) : super(key: key);

  @override
  State<ImageModerationAlert> createState() => _ImageModerationAlertState();
}

class _ImageModerationAlertState extends State<ImageModerationAlert> {

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
              Text(
                'The image you are trying to upload might be NSFW.',
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
