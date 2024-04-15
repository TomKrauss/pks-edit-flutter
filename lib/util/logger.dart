//
// logger.dart
//
// PKS-EDIT - Flutter
//
// Last modified: 2024
// Author: Tom Krauß
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class _SimpleLogPrinter extends LogPrinter {
  final String className;
  final bool printTime;
  ///
  /// Additional infos used in production environments to include like information about the current place (orgapath)
  /// or local host name etc...
  ///
  final List<String> additionalInfo;

  _SimpleLogPrinter(this.className, this.printTime, {this.additionalInfo = const[]});

  @override
  List<String> log(LogEvent event) {
    List<String> logEntries = [];
    var color = PrettyPrinter.defaultLevelColors[event.level]!;
    var emoji = PrettyPrinter.defaultLevelEmojis[event.level];

    var time = printTime
        ? DateFormat('yyyy-MM-dd HH:mm:ss.SSS ').format(DateTime.now())
        : '';
    if (!LoggerConfiguration().playful) {
      var prefix = additionalInfo.join(":");
      if (prefix.isNotEmpty) {
        prefix += ":";
      }
      logEntries.add("$prefix${event.level.name.toUpperCase()}:$time:$className:${event.message}");
    } else {
      logEntries.add(color('$emoji $time$className - ${event.message}'));
    }
    if (event.stackTrace != null) {
      logEntries.add(event.stackTrace.toString());
    }

    return logEntries;
  }
}

///
/// Class, which can be used to configure logging. Use factory constructor
/// for accessing it.
///
class LoggerConfiguration {
  ///
  /// Whether log output should be printed in a "playful" format using color coding and emojis to
  /// represent log levels.
  ///
  bool playful = true;
  /// The minimum log level of messages to show up in the log.
  Level logLevel = Level.trace;
  ///
  /// Can be assigned to display additional information fields in the log output created (like the orga path
  /// of a device / till producing the output or the local host name).
  ///
  List<String> additionalInfo = [];

  LoggerConfiguration._create();
  LogOutput _loggerOutput = ConsoleOutput();
  static final LoggerConfiguration _singleton = LoggerConfiguration._create();

  factory LoggerConfiguration() => _singleton;

  ///
  /// Creates the log filter.
  ///
  LogFilter createFilter() => ProductionFilter()..level = logLevel;

  ///
  /// Creates the log printer
  ///
  LogPrinter createPrinter(String className, bool printTime) => _SimpleLogPrinter(className, printTime, additionalInfo: additionalInfo);

  ///
  /// Invoke this to define a customer logger output.
  /// See for instance [MultiOutput] if you wish to
  /// log to a file and console at the same time.
  ///
  /// Should be invoked at application startup time.
  ///
  void setLoggerOutput(LogOutput newOutput) => _loggerOutput = newOutput;

  ///
  /// Add a file output to the list of output loggers.
  ///
  void addFileOutput(File file) {
    _loggerOutput = MultiOutput([
      _loggerOutput,
      FileOutput(file: file)
    ]);
  }
}


///
/// Can be used to create a logger logging for a [module] in PKS Edit.
///
Logger createLogger(String module) {
  var config = LoggerConfiguration();

  return Logger(printer: config.createPrinter(module, true),
      filter: config.createFilter(),
      output: config._loggerOutput);
}
