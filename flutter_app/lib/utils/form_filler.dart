import 'dart:math';
import '../models/evaluation.dart';

/// 评教方式
enum EvalMethod { good, bad, random }

/// 表单填充工具
class FormFiller {
  /// 从表单数据中提取问题列表
  static List<EvalQuestion> getQuestionList(Map<String, dynamic> formInfo) {
    final questions = <EvalQuestion>[];

    try {
      final wjzblist = formInfo['pjxtWjWjbReturnEntity']['wjzblist'] as List;
      final tklist = wjzblist[0]['tklist'] as List;

      for (final tk in tklist) {
        final options = <EvalOption>[];
        final xxlist = tk['xxlist'] as List? ?? [];

        for (final xx in xxlist) {
          options.add(EvalOption(
            id: xx['id'].toString(),
            content: xx['xxnr'] ?? '',
            pts: (xx['xxfz'] ?? 0).toDouble(),
          ));
        }

        // 按分数从高到低排序
        options.sort((a, b) => b.pts.compareTo(a.pts));

        questions.add(EvalQuestion(
          isChoice: tk['tkfl'] == '1',
          type: tk['tklx'] ?? '',
          id: tk['id'].toString(),
          options: options,
        ));
      }
    } catch (e) {
      // 解析失败返回空列表
    }

    return questions;
  }
}
