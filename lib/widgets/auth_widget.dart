import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/providers.dart';

class AuthWidget extends ConsumerWidget {
  const AuthWidget({Key? key, required this.signedInBuilder, required this.nonSignedInBuilder}) : super(key: key);

  final WidgetBuilder signedInBuilder;
  final WidgetBuilder nonSignedInBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateChanges = ref.watch(authStateChangesProvider);

    return authStateChanges.when(
        data: (user) {
          if(user != null) {
            return signedInBuilder(context);
          }
          return nonSignedInBuilder(context);
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (_,__) {
          return const Scaffold(
            body: Center(
              child: Text('There is a big problem...'),
            ),
          );
        }
    );
  }
}
