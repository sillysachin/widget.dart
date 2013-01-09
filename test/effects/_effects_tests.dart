library effects_tests;

import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:widget/effects.dart';
import 'package:bot/bot.dart';
import 'package:bot/bot_html.dart';
import 'package:bot/bot_test.dart';

part 'animation_core_tests.dart';
part 'element_animation_tests.dart';
part 'test_time_manager.dart';
part 'show_hide_tests.dart';

void main() {
  group('effects', () {
    test('asserts should be enabled', () {
      expect(() { assert(false); }, throwsAssertionError);
      expect(() { assert(true); }, returnsNormally);
    });

    registerAnimationCoreTests();
    registerElementAnimationTests();
    registerShowHideTests();
  });
}

void setupTestTimeManager() {
  AnimationQueue.timeManagerFactory = () {
    assert(_timeManagerInstance == null);
    return _timeManagerInstance = new TestTimeManager();
  };
}

void tearDownTestTimeManager() {
  AnimationQueue.disposeInstance();
  if(_timeManagerInstance != null) {
    assert(_timeManagerInstance.isDisposed);
    _timeManagerInstance = null;
  }
}

TestTimeManager _timeManagerInstance;

void _createPlayground() {
  final existing = _getPlayground();
  assert(existing == null);
  // assert no playground exists
  final pg = new DivElement();
  pg.classes.add('playground');
  document.body.append(pg);
  // insert it
}

void _cleanUpPlayground() {
  final existing = _getPlayground();
  assert(existing != null);
  existing.remove();
}

DivElement _getPlayground() => query('div.playground');
