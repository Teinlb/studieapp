import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studieapp/theme/app_theme.dart';

class PomodoroTimerView extends StatefulWidget {
  const PomodoroTimerView({super.key});

  @override
  State<PomodoroTimerView> createState() => _PomodoroTimerViewState();
}

class _PomodoroTimerViewState extends State<PomodoroTimerView> {
  static const int _workDuration = 25 * 60; // 25 minutes
  static const int _breakDuration = 5 * 60; // 5 minutes

  int _remainingTime = _workDuration;
  bool _isRunning = false;
  bool _isWorkSession = true;
  int _completedSessions = 0;

  late Timer _timer;

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _switchSession();
      }
    });
  }

  void _switchSession() {
    _timer.cancel();
    setState(() {
      _isWorkSession = !_isWorkSession;
      _remainingTime = _isWorkSession ? _workDuration : _breakDuration;

      if (_isWorkSession) {
        _completedSessions++;
      }

      _isRunning = false;
    });
  }

  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _remainingTime = _workDuration;
      _isRunning = false;
      _isWorkSession = true;
      _completedSessions = 0;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pomodoro Timer',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isWorkSession ? 'Studeer Sessie' : 'Pauze',
              textAlign: TextAlign.center,
              style: AppTheme.getOrbitronStyle(
                size: 28,
                color: _isWorkSession ? AppTheme.accentOrange : Colors.green,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: 1 -
                          (_remainingTime /
                              (_isWorkSession
                                  ? _workDuration
                                  : _breakDuration)),
                      backgroundColor: AppTheme.secondaryBlue,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isWorkSession ? AppTheme.accentOrange : Colors.green,
                      ),
                      strokeWidth: 15,
                    ),
                  ),
                  Text(
                    _formatTime(_remainingTime),
                    style: AppTheme.getOrbitronStyle(
                      size: 56,
                      weight: FontWeight.bold,
                      color:
                          _isWorkSession ? AppTheme.accentOrange : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Voltooide Sessies: $_completedSessions',
              textAlign: TextAlign.center,
              style: AppTheme.getOrbitronStyle(
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning
                        ? AppTheme.secondaryBlue
                        : AppTheme.accentOrange,
                    foregroundColor: AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _isRunning ? 'Pauzeren' : 'Starten',
                    style: AppTheme.getOrbitronStyle(
                      size: 20,
                      weight: FontWeight.bold,
                      color: _isRunning
                          ? AppTheme.accentOrange
                          : AppTheme.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton(
                  onPressed: _resetTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed.withOpacity(0.9),
                    foregroundColor: AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Resetten',
                    style: AppTheme.getOrbitronStyle(
                      size: 20,
                      weight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
