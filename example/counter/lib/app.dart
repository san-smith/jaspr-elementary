import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import 'components/counter.dart';

// The main component of your application.
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    // This method is rerun every time the component is rebuilt.

    // Renders a <div class="main"> html element with children.
    print('Main component build() called');
    return div(classes: 'main', [
      CounterComponent(),
    ]);
  }
}
