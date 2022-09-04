import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import 'PollChoiceModel.dart';

@immutable
class PollModel extends Equatable{
  final String id;
  final String question;
  final List<PollChoiceModel> choices;
  final List<dynamic> userIDsWhoHaveVoted;
  final String endDate;

  const PollModel({
    required this.id,
    required this.question,
    required this.choices,
    required this.userIDsWhoHaveVoted,
    required this.endDate,
  });

  @override
  List<dynamic> get props => [
    id,
    question,
    choices,
    userIDsWhoHaveVoted,
    endDate,
  ];

  @override
  bool get stringify => true;

  factory PollModel.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for poll model: $documentId');
    }

    final id = data['id'] as String?;
    if (id == null) {
      throw StateError('missing id for poll model: $documentId');
    }

    final question = data['question'] as String?;
    if (question == null) {
      throw StateError('missing question for poll model: $documentId');
    }

    List<PollChoiceModel> choices = [];
    final choicesRawData = data['choices'] as List<dynamic>;
    for(Map<String, dynamic>? choice in choicesRawData) {
      choices.add(PollChoiceModel.fromMap(choice));
    }

    final userIDsWhoHaveVoted = data['userIDsWhoHaveVoted'] as List<dynamic>?;
    if (userIDsWhoHaveVoted == null) {
      throw StateError('missing userIDsWhoHaveVoted for poll model: $documentId');
    }

    final endDate = data['endDate'] as String?;
    if (endDate == null) {
      throw StateError('missing endDate for poll model: $documentId');
    }

    return PollModel(
      id: id,
      question: question,
      choices: choices,
      userIDsWhoHaveVoted: userIDsWhoHaveVoted,
      endDate: endDate,
    );
  }

  Map<String, dynamic> toMap() {
    List<Map<String, dynamic>?> mappedChoicesList = [];
    for(PollChoiceModel choiceModel in choices) {
      mappedChoicesList.add(choiceModel.toMap());
    }
    return {
      'id': id,
      'question': question,
      'choices': mappedChoicesList,
      'userIDsWhoHaveVoted': userIDsWhoHaveVoted,
      'endDate': endDate,
    };
  }
}