import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_elementary/jaspr_elementary.dart';

import 'counter_vm.dart';

/// Компонент счётчика.
///
/// Использует Elementary архитектуру для разделения логики и UI.
/// ViewModel предоставляет данные и методы, компонент только отображает.
class CounterComponent extends ElementaryComponent<ICounterViewModel> {
  /// Идентификатор компонента для демонстрации update lifecycle.
  final String id;

  /// Заголовок приложения.
  final String title;

  const CounterComponent({
    super.key,
    this.id = 'default',
    this.title = 'Jaspr Elementary Counter',
    ViewModelFactory wmFactory = counterViewModelFactory,
  }) : super(wmFactory);

  @override
  Component build(ICounterViewModel vm) {
    print('[CounterComponent] build() called');

    return div(
      classes: 'counter-container',
      styles: Styles(
        maxWidth: 400.px,
        padding: Padding.all(20.px),
      ),
      [
        // Заголовок
        h1(
          styles: Styles(
            color: Colors.darkBlue,
            textAlign: TextAlign.center,
          ),
          [.text(title)],
        ),

        // Информация о жизненном цикле
        div(
          classes: 'lifecycle-info',
          styles: Styles(
            padding: Padding.all(10.px),
            margin: Padding.symmetric(vertical: 10.px),
            backgroundColor: Colors.slateGray,
          ),
          [
            p(
              styles: Styles(
                color: Colors.darkGray,
                fontSize: 12.px,
              ),
              [
                .text('Lifecycle: ${vm.lifecycleStats}'),
              ],
            ),
            p(
              styles: Styles(
                color: Colors.darkGray,
                fontSize: 12.px,
              ),
              [
                .text('Component ID: $id'),
              ],
            ),
          ],
        ),

        // Значение счётчика с подпиской на Stream
        StreamBuilder<int>(
          stream: vm.countStream,
          initialData: vm.count,
          builder: (context, snapshot) {
            return div(
              classes: 'count-display',
              styles: Styles(
                padding: Padding.all(20.px),
                margin: Padding.symmetric(vertical: 20.px),
                textAlign: TextAlign.center,
                backgroundColor: Colors.lightBlue,
              ),
              [
                span(
                  styles: Styles(fontSize: 18.px),
                  [Component.text('Count: ')],
                ),
                span(
                  styles: Styles(
                    color: Colors.blue,
                    fontSize: 32.px,
                    fontWeight: FontWeight.bold,
                  ),
                  [Component.text('${snapshot.data ?? 0}')],
                ),
              ],
            );
          },
        ),

        // Кнопки управления
        div(
          classes: 'button-group',
          styles: Styles(
            display: Display.flex,
            margin: Padding.symmetric(vertical: 20.px),
            justifyContent: JustifyContent.center,
            gap: Gap(row: 10.px, column: 10.px),
          ),
          [
            _buildButton(
              text: '-',
              onClick: (_) => vm.decrement(),
              color: Colors.red,
            ),
            _buildButton(
              text: 'Reset',
              onClick: (_) => vm.reset(),
              color: Colors.orange,
            ),
            _buildButton(
              text: '+',
              onClick: (_) => vm.increment(),
              color: Colors.green,
            ),
          ],
        ),

        // Кнопка для демонстрации обработки ошибок
        div(
          styles: Styles(
            textAlign: TextAlign.center,
          ),
          [
            _buildButton(
              text: 'Trigger Error',
              onClick: (_) => vm.triggerError(),
              color: Colors.darkGray,
              small: true,
            ),
          ],
        ),

        // Инструкция
        div(
          styles: Styles(
            padding: Padding.all(15.px),
            backgroundColor: Colors.lightYellow,
          ),
          [
            h3(
              styles: Styles(
                fontSize: 14.px,
              ),
              [Component.text('📚 Как это работает:')],
            ),
            ul(
              styles: Styles(
                fontSize: 12.px,
              ),
              [
                _buildListItem('ViewModel создаётся 1 раз при первом mount'),
                _buildListItem('ViewModel сохраняется при пересоздании компонента'),
                _buildListItem('Stream уведомляет UI об изменениях'),
                _buildListItem('Ошибки обрабатываются через onErrorHandle'),
                _buildListItem('Смотрите консоль для логов жизненного цикла'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// Вспомогательный метод для создания кнопок.
  Component _buildButton({
    required String text,
    required EventCallback onClick,
    required Color color,
    bool small = false,
  }) {
    return button(
      events: {'click': onClick},
      styles: Styles(
        padding: small ? Padding.symmetric(horizontal: 10.px, vertical: 5.px) : Padding.all(15.px),
        cursor: Cursor.pointer,
        color: Colors.white,
        fontSize: small ? 12.px : 16.px,
        backgroundColor: color,
      ),
      [Component.text(text)],
    );
  }

  /// Вспомогательный метод для создания элементов списка.
  Component _buildListItem(String text) {
    return li(
      styles: Styles(),
      [Component.text(text)],
    );
  }
}
// class Counter extends StatefulComponent {
//   const Counter({super.key});

//   @override
//   State<Counter> createState() => CounterState();
// }

// class CounterState extends State<Counter> {
//   int count = 0;

//   @override
//   Component build(BuildContext context) {
//     return div([
//       div(classes: 'counter', [
//         button(
//           onClick: () {
//             setState(() => count--);
//           },
//           [.text('-')],
//         ),
//         span([.text('$count')]),
//         button(
//           onClick: () {
//             setState(() => count++);
//           },
//           [.text('+')],
//         ),
//       ]),
//     ]);
//   }
// }
