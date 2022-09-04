import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportPostModal extends StatefulWidget {
  const ReportPostModal({Key? key}) : super(key: key);

  @override
  State<ReportPostModal> createState() => _ReportPostModalState();
}

class _ReportPostModalState extends State<ReportPostModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.grey[200]
                ),
                height: 5,
                width: 50,
              ),
              const SizedBox(height: 20),
              _tile(
                Colors.black,
                const Icon(
                  Icons.report_gmailerrorred,
                  color: Colors.black,
                  size: 32,
                ),
                'Report',
                () { },
              ),
              const SizedBox(height: 12),
              _tile(
                Colors.black,
                const Icon(
                  Icons.link,
                  color: Colors.black,
                  size: 32,
                ),
                'Share Link',
                    () { },
              ),
              const SizedBox(height: 12),
              _tile(
                Colors.black,
                const Icon(
                  Icons.edit_outlined,
                  color: Colors.black,
                  size: 32,
                ),
                'Edit Post',
                    () { },
              ),
              const SizedBox(height: 12),
              _tile(
                Colors.red,
                const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 32,
                ),
                'Delete',
                    () { },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(Color color, Icon icon, String label, void Function() onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: icon,
        horizontalTitleGap: 5,
        title: Text(
          label,
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
