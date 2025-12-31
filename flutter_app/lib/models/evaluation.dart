/// 评教选项
class EvalOption {
  final String id;
  final String content;
  final double pts;

  EvalOption({
    required this.id,
    required this.content,
    required this.pts,
  });
}

/// 评教问题
class EvalQuestion {
  final bool isChoice;
  final String type;
  final String id;
  final List<EvalOption> options;

  EvalQuestion({
    required this.isChoice,
    required this.type,
    required this.id,
    required this.options,
  });
}

/// 课程信息
class CourseInfo {
  final String id;
  final String name;
  final String teacher;
  final int totalCount;
  final int evaluatedCount;
  final Map<String, dynamic> rawData;

  CourseInfo({
    required this.id,
    required this.name,
    required this.teacher,
    required this.totalCount,
    required this.evaluatedCount,
    required this.rawData,
  });

  bool get isEvaluated => evaluatedCount >= totalCount;
}

/// 评教任务
class EvalTask {
  final String id;
  final String name;

  EvalTask({required this.id, required this.name});
}

/// 问卷信息
class Questionnaire {
  final String id;
  final String name;
  final String? msid;
  final Map<String, dynamic> rawData;

  Questionnaire({
    required this.id,
    required this.name,
    this.msid,
    required this.rawData,
  });
}
