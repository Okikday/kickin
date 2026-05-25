import 'dart:developer' as dev;

import 'package:logger/logger.dart';

class _DevLogOutput extends LogOutput {
  final String name;

  _DevLogOutput({this.name = 'KApi'});

  @override
  void output(OutputEvent event) => dev.log(event.lines.join('\n'), name: name);
}

class NetworkLog {
  static final Logger _logger = Logger(
    filter: ProductionFilter(),
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, printEmojis: true, colors: true, lineLength: 80),
    output: _DevLogOutput(name: 'kickin.network'),
  );

  // Expose basic methods
  static void request(String message) => _logger.i(message);
  static void success(String message) => _logger.d(message);
  static void error(String message, [dynamic error]) => _logger.e(message, error: error);
}
