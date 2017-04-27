import 'dart:io';
import 'dart:convert';
import 'package:meta/meta.dart';

class _TestFailure implements Exception {
  final String key;
  final String actual;
  final String expected;
  _TestFailure(
      {@required this.key, @required this.actual, @required this.expected});
}

class _Result {
  final Map<String, dynamic> config;
  bool passed;
  String message;

  _Result(this.config) {
    try {
      passed = runTest();
      message = 'PASS';
    } catch (e) {
      if (e is _TestFailure) {
        message = '${e.key} mismatch: ${e.actual} != ${e.expected}';
      } else {
        message = 'Unexpected Exception -- ' + e.toString();
      }
      passed = config['failure'] == true;
    }
  }

  _check(String actual, String key) {
    String expected = config['key'];
    if (actual != expected) {
      throw new _TestFailure(
        key: key,
        actual: actual,
        expected: expected,
      );
    }
  }

  bool runTest() {
    Uri uri = Uri.parse(config['input']);
    if (config['failure'] == true) {
      throw new _TestFailure(
        key: 'failure',
        actual: 'false',
        expected: 'true',
      );
    }

    // _check(uri.base, 'base');
    // _check(uri.href, 'href');
    _check(uri.origin, 'origin');
    _check(uri.scheme + ':', 'protocol');
    _check(uri.userInfo, 'user');
    // _check(uri.password, 'password');
    _check(uri.host, 'host');
    _check(uri.port.toString(), 'port');
    _check(uri.path, 'pathname');
    // _check(uri.search, 'search');
    // _check(uri.hash, 'hash');
    return true;
  }
}

void main() {
  File testData = new File('urltestdata.json');
  List<Map<String, dynamic>> tests = JSON.decode(testData.readAsStringSync());

  List<_Result> results =
      tests.where((var config) => config is Map).map((var config) {
    return new _Result(config);
  });

  List<_Result> failures = results.where((r) => !r.passed);
  int passCount = results.length - failures.length;
  print('${passCount} of ${results.length} passed.');
  print('Failures:');
  failures.forEach((var result) {
    if (!result.passed) {
      String encodedInput = Uri.encodeFull(result.config['input']);
      print("TEST: ${encodedInput}");
      print("  RESULT: ${result.message}");
    }
  });
}
