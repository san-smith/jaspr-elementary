import 'package:jaspr_elementary_test/jaspr_elementary_test.dart';
import 'package:test/test.dart';

void main() {
  test('library exports load', () {
    expect(testComponentModel, isA<Function>());
  });
}
