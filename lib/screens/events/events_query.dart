import 'package:sea/models/SEAUser.dart';
import 'package:tuple/tuple.dart';

Tuple4<SEAUser?, bool?, String?, String?> EventsQuery({SEAUser? user, bool? going, String? groupID, String? gameID}) {
  return Tuple4(user, going, groupID, gameID);
}
