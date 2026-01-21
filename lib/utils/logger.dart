// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';

class FileOutput extends LogOutput {
  final File? _file;
  final bool overrideExisting;
  final Encoding encoding;
  IOSink? _sink;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  FileOutput({File? file, this.overrideExisting = false, this.encoding = utf8})
    : _file = file;

  @override
  void output(OutputEvent event) {
    final file = _file;
    if (file == null) return;

    try {
      _sink ??= file.openWrite(
        mode: overrideExisting ? FileMode.writeOnly : FileMode.writeOnlyAppend,
        encoding: encoding,
      );

      final timestamp = _dateFormat.format(DateTime.now());
      final level = event.level.name.toUpperCase().padRight(7);

      for (final line in event.lines) {
        _sink!.writeln('[$timestamp] [$level] $line');
      }

      // Flush immediately to ensure logs are written
      _sink!.flush();
    } catch (e) {
      // Silently fail if file writing fails to avoid breaking the app
    }
  }

  @override
  Future<void> destroy() async {
    await _sink?.close();
    _sink = null;
  }
}

class AppLogger {
  static Logger? _logger;
  static FileOutput? _fileOutput;
  static File? _logFile;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(directory.path, 'logs'));

      // Create logs directory if it doesn't exist
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Create log file with timestamp
      final timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final logFileName = 'app_log_$timestamp.txt';
      _logFile = File(path.join(logDir.path, logFileName));

      // Initialize file output
      _fileOutput = FileOutput(file: _logFile!, overrideExisting: false);

      // Create logger with both console and file output
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: MultiOutput([ConsoleOutput(), _fileOutput!]),
      );

      _initialized = true;

      // Log initialization
      _logger!.i('========================================');
      _logger!.i(
        'Logger initialized - Logs will be saved to: ${_logFile!.path}',
      );
      _logger!.i('========================================');
    } catch (e) {
      // If file logging fails, fall back to console only
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      _logger!.w('Failed to initialize file logging: $e');
      _initialized = true;
    }
  }

  static Logger get _instance {
    if (!_initialized) {
      // Synchronous fallback if not initialized
      _logger ??= Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );
      _initialized = true;
    }
    return _logger!;
  }

  static File? get logFile => _logFile;

  static String? get logFilePath => _logFile?.path;

  static Future<void> clearLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
        _logger?.i('Log file cleared');
      }
    } catch (e) {
      _logger?.w('Failed to clear log file: $e');
    }
  }

  static Future<List<File>> getLogFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logDir = Directory(path.join(directory.path, 'logs'));

      if (!await logDir.exists()) {
        return [];
      }

      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.txt'))
          .cast<File>()
          .toList();

      // Sort by modification date (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e) {
      _logger?.w('Failed to get log files: $e');
      return [];
    }
  }

  static void debug(dynamic message) {
    _instance.d(message);
  }

  static void info(dynamic message) {
    _instance.i(message);
  }

  static void warning(dynamic message) {
    _instance.w(message);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(dynamic message) {
    _instance.v(message);
  }

  static void wtf(dynamic message) {
    _instance.wtf(message);
  }
}
