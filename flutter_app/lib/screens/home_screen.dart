import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/evaluation_service.dart';
import '../models/evaluation.dart';
import '../utils/form_filler.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  final Dio dio;
  const HomeScreen({super.key, required this.dio});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final EvaluationService _evalService;
  EvalTask? _currentTask;
  EvalMethod _method = EvalMethod.good;
  bool _isLoading = true;
  String _status = '正在获取任务...';

  @override
  void initState() {
    super.initState();
    _evalService = EvaluationService(widget.dio);
    _loadTask();
  }

  Future<void> _loadTask() async {
    final task = await _evalService.getLatestTask();
    if (!mounted) return;

    setState(() {
      _currentTask = task;
      _isLoading = false;
      _status = task != null ? '已获取任务' : '暂无评教任务';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('北航评教助手')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_currentTask == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadTask();
              },
              child: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTaskCard(),
          const SizedBox(height: 24),
          _buildMethodSelector(),
          const Spacer(),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildTaskCard() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.assignment, color: Colors.blue),
        title: const Text('当前任务'),
        subtitle: Text(_currentTask!.name),
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('评教方式', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        _buildMethodTile(EvalMethod.good, '好评模式', '约93分'),
        _buildMethodTile(EvalMethod.bad, '及格模式', '60分'),
        _buildMethodTile(EvalMethod.random, '随机模式', '60-100分'),
      ],
    );
  }

  Widget _buildMethodTile(EvalMethod method, String title, String sub) {
    return RadioListTile<EvalMethod>(
      value: method,
      groupValue: _method,
      onChanged: (v) => setState(() => _method = v!),
      title: Text(title),
      subtitle: Text(sub),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _startEvaluation,
        child: const Text('开始评教'),
      ),
    );
  }

  void _startEvaluation() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          dio: widget.dio,
          taskId: _currentTask!.id,
          method: _method,
        ),
      ),
    );
  }
}
