import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class PollChoiceModel extends Equatable{
  final String id;
  late String choiceText;
  final List<dynamic> membersWhoSelected;

  PollChoiceModel({
    required this.id,
    required this.choiceText,
    required this.membersWhoSelected,
  });

  @override
  List<dynamic> get props => [
    id,
    choiceText,
    membersWhoSelected,
  ];

  @override
  bool get stringify => true;

  factory PollChoiceModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw StateError('missing data for poll choice model');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for poll choice model');
    }

    final choiceText = data['choiceText'] as String?;
    if (choiceText == null) {
      throw StateError('missing choiceText for poll choice model');
    }

    final membersWhoSelected = data['membersWhoSelected'] as List<dynamic>?;
    if (membersWhoSelected == null) {
      throw StateError('missing membersWhoSelected for poll choice model');
    }

    return PollChoiceModel(
      id: id,
      choiceText: choiceText,
      membersWhoSelected: membersWhoSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'choiceText': choiceText,
      'membersWhoSelected': membersWhoSelected,
    };
  }
}