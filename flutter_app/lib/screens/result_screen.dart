import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/evaluation_service.dart';
import '../models/evaluation.dart';
import '../utils/form_filler.dart';

class ResultScreen extends StatefulWidget {
  final Dio dio;
  final String taskId;
  final EvalMethod method;

  const ResultScreen({
    super.key,
    required this.dio,
    required this.taskId,
    required this.method,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final EvaluationService _evalService;
  final List<EvalResult> _results = [];
  bool _isRunning = true;
  int _total = 0;
  int _completed = 0;
  int _skipped = 0;

  @override
  void initState() {
    super.initState();
    _evalService = EvaluationService(widget.dio);
    _startEvaluation();
  }

  Future<void> _startEvaluation() async {
    final questionnaires = await _evalService.getQuestionnaireList(widget.taskId);

    for (final q in questionnaires) {
      if (!_isRunning) break;

      await _evalService.setEvaluatingMethod(q);
      final courses = await _evalService.getCourseList(q.id);

      setState(() => _total += courses.length);

      for (final course in courses) {
        if (!_isRunning) break;

        if (course.isEvaluated) {
          setState(() => _skipped++);
          continue;
        }

        final result = await _evalService.evaluateCourse(course, widget.method);
        setState(() {
          _results.add(result);
          _completed++;
        });

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    setState(() => _isRunning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评教结果')),
      body: Column(
        children: [
          _buildProgress(),
          Expanded(child: _buildResultList()),
          if (!_isRunning && _results.isNotEmpty) _buildChart(),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final progress = _total > 0 ? (_completed + _skipped) / _total : 0.0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text(
            _isRunning
                ? '进度: ${_completed + _skipped}/$_total (跳过: $_skipped)'
                : '完成! 评教: $_completed, 跳过: $_skipped',
          ),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    if (_results.isEmpty) {
      return const Center(child: Text('等待评教结果...'));
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (ctx, i) {
        final r = _results[i];
        return ListTile(
          leading: Icon(
            r.success ? Icons.check_circle : Icons.error,
            color: r.success ? Colors.green : Colors.red,
          ),
          title: Text(r.courseName),
          subtitle: Text(r.message),
          trailing: Text('${r.score.toInt()}分'),
        );
      },
    );
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          barGroups: _buildBarGroups(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Text('${v.toInt() + 1}'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return _results.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.score,
            color: e.value.success ? Colors.blue : Colors.red,
          ),
        ],
      );
    }).toList();
  }
}
