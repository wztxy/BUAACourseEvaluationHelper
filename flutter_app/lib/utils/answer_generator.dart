import 'dart:math';
import '../models/evaluation.dart';
import 'form_filler.dart';

/// 答案生成器
class AnswerGenerator {
  /// 生成答案
  static List<EvalOption> generate(
    List<EvalQuestion> questions,
    EvalMethod method,
  ) {
    final choiceQuestions = questions.where((q) => q.isChoice).toList();

    switch (method) {
      case EvalMethod.good:
        return _genGoodAnswer(choiceQuestions);
      case EvalMethod.bad:
        return _genBadAnswer(choiceQuestions);
      case EvalMethod.random:
        return _genRandomAnswer(choiceQuestions);
    }
  }

  /// 好评：第一题选第二好，其余选最好
  static List<EvalOption> _genGoodAnswer(List<EvalQuestion> questions) {
    final answers = <EvalOption>[];
    for (int i = 0; i < questions.length; i++) {
      final opts = questions[i].options;
      if (i == 0 && opts.length > 1) {
        answers.add(opts[1]); // 第二好的选项
      } else {
        answers.add(opts[0]); // 最好的选项
      }
    }
    return answers;
  }

  /// 差评：刚好60分
  static List<EvalOption> _genBadAnswer(List<EvalQuestion> questions) {
    return _dpAnswer(questions, 60);
  }

  /// 随机：60-100分随机
  static List<EvalOption> _genRandomAnswer(List<EvalQuestion> questions) {
    final target = 60 + Random().nextInt(41);
    return _dpAnswer(questions, target);
  }

  /// 动态规划找到目标分数的答案组合
  static List<EvalOption> _dpAnswer(
    List<EvalQuestion> questions,
    int threshold,
  ) {
    // 计算最大可能分数
    int maxScore = 0;
    for (final q in questions) {
      if (q.options.isNotEmpty) {
        maxScore += q.options[0].pts.toInt();
      }
    }

    // DP数组
    final dp = List.filled(maxScore + 1, false);
    final path = List<List<int>>.filled(maxScore + 1, []);
    dp[0] = true;

    for (int i = 0; i < questions.length; i++) {
      final newDp = List.filled(maxScore + 1, false);
      final newPath = List<List<int>>.filled(maxScore + 1, []);

      for (int s = 0; s <= maxScore; s++) {
        if (!dp[s]) continue;

        for (int j = 0; j < questions[i].options.length; j++) {
          final pts = questions[i].options[j].pts.toInt();
          final newS = s + pts;
          if (newS <= maxScore && !newDp[newS]) {
            newDp[newS] = true;
            newPath[newS] = [...path[s], j];
          }
        }
      }

      for (int s = 0; s <= maxScore; s++) {
        dp[s] = newDp[s];
        path[s] = newPath[s];
      }
    }

    // 找到>=threshold的最小分数
    for (int s = threshold; s <= maxScore; s++) {
      if (dp[s] && path[s].length == questions.length) {
        return List.generate(
          questions.length,
          (i) => questions[i].options[path[s][i]],
        );
      }
    }

    // 兜底：返回最高分答案
    return questions.map((q) => q.options[0]).toList();
  }
}
