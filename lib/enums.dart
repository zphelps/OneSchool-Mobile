enum UserRole {
  administrator,
  manager,
  teacher,
  staff,
  studentLeader,
  student,
  parent,
  guest,
}

extension UserRoleExtension on UserRole {
  static const names = {
    UserRole.administrator: 'Administrator',
    UserRole.manager: 'Manager',
    UserRole.teacher: 'Teacher',
    UserRole.staff: 'Staff',
    UserRole.studentLeader: 'Student Leader',
    UserRole.student: 'Student',
    UserRole.parent: 'Parent',
    UserRole.guest: 'Guest',
  };

  String? get name => names[this];
}

UserRole stringToUserRole(String userRole) {
  if(userRole == 'Administrator') {
    return UserRole.administrator;
  }
  else if(userRole == 'Manager') {
    return UserRole.manager;
  }
  else if(userRole == 'Teacher') {
    return UserRole.teacher;
  }
  else if(userRole == 'Staff') {
    return UserRole.staff;
  }
  else if(userRole == 'Student Leader') {
    return UserRole.studentLeader;
  }
  else if(userRole == 'Student') {
    return UserRole.student;
  }
  else if(userRole == 'Parent') {
    return UserRole.parent;
  }
  else {
    return UserRole.guest;
  }
}


enum Season {
  _2019_2020,
  _2020_2021,
  _2021_2022,
  _2022_2023,
}

extension SeasonExtension on Season {
  static const names = {
    Season._2019_2020: '2019-2020',
    Season._2020_2021: '2020-2021',
    Season._2021_2022: '2021-2022',
    Season._2022_2023: '2022-2023',
  };

  String? get name => names[this];
}

String getCurrentSeason({String? gameDataTimeString}) {
  int year = gameDataTimeString != null ? DateTime.parse(gameDataTimeString).year : DateTime.now().year;
  int month = gameDataTimeString != null ? DateTime.parse(gameDataTimeString).month : DateTime.now().month;
  if(month >= 7) {
    return SeasonExtension.names.values.where((element) => element == '$year-${year+1}').toList().first;
  }
  else {
    return SeasonExtension.names.values.where((element) => element == '${year-1}-$year').toList().first;
  }
}