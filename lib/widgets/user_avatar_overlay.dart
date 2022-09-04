import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/SEAUser.dart';
import 'package:sea/services/providers.dart';

class UserAvatarOverlay extends ConsumerWidget {
  const UserAvatarOverlay({required this.userIDs, this.isGame = false});

  final List<dynamic> userIDs;
  final bool isGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String attenderName = isGame ? 'Fan' : 'RSVP';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            children: <Widget>[
              for(int i = 0; i < (userIDs.length < 6 ? userIDs.length : 6); i++)
                Align(
                    widthFactor: i != userIDs.length ? i + 1 : 0,
                    child: userAvatar(userIDs[i], ref)
                ),
            ],
          ),
          if(userIDs.length > 6)
            Align(
              widthFactor: userIDs.length >= 3 ? 0.4 : 1.3,
              child: Text(
                '+ ${userIDs.length-6} others}',
                style: GoogleFonts.inter(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w400,
                  fontSize: 14
                ),
              ),
            ),
          if(userIDs.length <= 6)
            Align(
              widthFactor: userIDs.length >= 3 ? 0.4 : 1.3,
              child: Text(
                '${userIDs.length} ${userIDs.length > 1 ? '${attenderName}s' :  attenderName}',
                style: GoogleFonts.inter(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w400,
                    fontSize: 14
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget userAvatar(String userID, WidgetRef ref) {
    final userAsyncValue = ref.watch(getUserStreamProvider(userID));
    return userAsyncValue.when(
      data: (user) {
        return CircleAvatar(
          radius: 23.25,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(user.profileImageURL),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const Text('Error'),
    );
  }
}
