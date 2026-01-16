class TrainingModel {
  final String? courseName;
  final String? startCourse;
  final String? endCourse;

  const TrainingModel({this.courseName, this.startCourse, this.endCourse});

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      courseName: json['course_name'] as String?,
      startCourse: json['start_course']?.toString(),
      endCourse: json['end_course']?.toString(),
    );
  }

  String get displayName => courseName ?? '-';
  String get displayPeriod => '${startCourse ?? '-'} - ${endCourse ?? '-'}';
}
