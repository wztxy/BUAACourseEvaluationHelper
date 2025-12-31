import 'package:dio/dio.dart';
import '../models/evaluation.dart';
import '../utils/form_filler.dart';
import '../utils/answer_generator.dart';

/// 评教结果
class EvalResult {
  final bool success;
  final String courseName;
  final double score;
  final String message;

  EvalResult({
    required this.success,
    required this.courseName,
    required this.score,
    required this.message,
  });
}

class EvaluationService {
  static const String baseUrl = 'https://spoc.buaa.edu.cn/pjxt/';

  final Dio _dio;

  EvaluationService(this._dio);

  /// 获取最新评教任务
  Future<EvalTask?> getLatestTask() async {
    try {
      final url = '${baseUrl}personnelEvaluation/listObtainPersonnelEvaluationTasks';
      final resp = await _dio.get(url, queryParameters: {
        'pageNum': 1,
        'pageSize': 1,
      });

      final list = resp.data['data']['list'] as List?;
      if (list == null || list.isEmpty) return null;

      final task = list[0];
      return EvalTask(
        id: task['id'].toString(),
        name: task['rwmc'] ?? '未知任务',
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取问卷列表
  Future<List<Questionnaire>> getQuestionnaireList(String taskId) async {
    try {
      final url = '${baseUrl}evaluationMethodSix/getQuestionnaireListToTask';
      final resp = await _dio.get(url, queryParameters: {
        'rwid': taskId,
        'pageNum': 1,
        'pageSize': 999,
      });

      final list = resp.data['data']['list'] as List? ?? [];
      return list.map((q) => Questionnaire(
        id: q['id'].toString(),
        name: q['wjmc'] ?? '',
        msid: q['msid']?.toString(),
        rawData: q,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// 设置评教模式
  Future<bool> setEvaluatingMethod(Questionnaire qinfo) async {
    try {
      final msid = qinfo.msid;
      if (msid == '1') return true; // 已是模式一

      final url = msid == '2'
          ? '${baseUrl}evaluationMethodSix/reviseQuestionnairePattern'
          : '${baseUrl}evaluationMethodSix/confirmQuestionnairePattern';

      await _dio.post(url, data: {
        'wjid': qinfo.id,
        'msid': '1',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取课程列表
  Future<List<CourseInfo>> getCourseList(String qid) async {
    try {
      final url = '${baseUrl}evaluationMethodSix/getRequiredReviewsData';
      final resp = await _dio.get(url, queryParameters: {
        'sfyp': 0,
        'wjid': qid,
        'pageNum': 1,
        'pageSize': 999,
      });

      final list = resp.data['data']['list'] as List? ?? [];
      return list.map((c) => CourseInfo(
        id: c['id'].toString(),
        name: c['kcmc'] ?? '未知课程',
        teacher: c['jsxm'] ?? '未知教师',
        totalCount: c['xypjcs'] ?? 1,
        evaluatedCount: c['ypjcs'] ?? 0,
        rawData: c,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// 评教单个课程
  Future<EvalResult> evaluateCourse(
    CourseInfo course,
    EvalMethod method,
  ) async {
    try {
      // 获取题目数据
      final raw = course.rawData;
      final topicUrl = '${baseUrl}evaluationMethodSix/getQuestionnaireTopic';
      final topicResp = await _dio.get(topicUrl, queryParameters: {
        'wjid': raw['wjid'],
        'pjdxid': raw['pjdxid'],
        'pjlcid': raw['pjlcid'],
        'pjfsid': raw['pjfsid'],
        'sfnm': raw['sfnm'],
        'pjdxlx': raw['pjdxlx'],
      });

      final formInfo = topicResp.data['data'];
      final questions = FormFiller.getQuestionList(formInfo);
      final answers = AnswerGenerator.generate(questions, method);

      // 计算总分
      double totalScore = 0;
      for (final ans in answers) {
        totalScore += ans.pts;
      }

      // 构建提交数据
      final submitData = _buildSubmitData(formInfo, questions, answers);

      // 提交
      final submitUrl = '${baseUrl}evaluationMethodSix/submitSaveEvaluation';
      final submitResp = await _dio.post(submitUrl, data: submitData);

      final success = submitResp.data['code'] == 200;
      return EvalResult(
        success: success,
        courseName: course.name,
        score: totalScore,
        message: success ? '评教成功' : (submitResp.data['msg'] ?? '评教失败'),
      );
    } catch (e) {
      return EvalResult(
        success: false,
        courseName: course.name,
        score: 0,
        message: '评教出错: $e',
      );
    }
  }

  /// 构建提交数据
  Map<String, dynamic> _buildSubmitData(
    Map<String, dynamic> formInfo,
    List<EvalQuestion> questions,
    List<EvalOption> answers,
  ) {
    final baseInfo = formInfo['pjxtPjjgPjjgckb'][1];
    final choiceQuestions = questions.where((q) => q.isChoice).toList();
    final nonChoiceQuestions = questions.where((q) => !q.isChoice).toList();

    // 构建答案列表
    final answerList = <Map<String, dynamic>>[];
    for (int i = 0; i < choiceQuestions.length; i++) {
      answerList.add({
        'tkid': choiceQuestions[i].id,
        'xxid': answers[i].id,
      });
    }

    // 非选择题默认空答案
    for (final q in nonChoiceQuestions) {
      answerList.add({
        'tkid': q.id,
        'xxid': '',
      });
    }

    return {
      ...baseInfo,
      'dtlist': answerList,
    };
  }
}
