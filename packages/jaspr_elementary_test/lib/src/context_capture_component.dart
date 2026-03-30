import 'package:jaspr/jaspr.dart';

/// Builds an empty subtree and reports the [BuildContext] passed to [build].
final class ContextCaptureComponent extends StatelessComponent {
  const ContextCaptureComponent(this.onContext, {super.key});

  final void Function(BuildContext context) onContext;

  @override
  Component build(BuildContext context) {
    onContext(context);
    return Component.text('');
  }
}
