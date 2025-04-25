import 'package:flutter/material.dart';
import 'package:novastate/novastate.dart';
import 'pages/user_profile_page.dart';
import 'pages/async_data_page.dart';

class AppState {
  final int counter;
  final String currentRoute;

  const AppState({
    this.counter = 0,
    this.currentRoute = '/home',
  });

  AppState copyWith({
    int? counter,
    String? currentRoute,
  }) {
    return AppState(
      counter: counter ?? this.counter,
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

void main() {
  final appStateStore = Store<AppState>(const AppState());

  runApp(
    StateProvider<AppState>(
      store: appStateStore,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaState Demo',
      theme: ThemeData.light(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StateProvider.storeOf<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NovaState Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ví dụ về Counter:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            StateSelector<AppState, int>(
              selector: (state) => state.counter,
              builder: (context, counter) {
                print('StateSelector: Counter value changed to $counter');
                return Text(
                  '$counter',
                  style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Decrementing counter');
                    store.update((state) => state.copyWith(
                          counter: state.counter - 1,
                        ));
                  },
                  child: const Text('Giảm -'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    print('Incrementing counter');
                    store.update((state) => state.copyWith(
                          counter: state.counter + 1,
                        ));
                  },
                  child: const Text('Tăng +'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Text(
              'Ví dụ khác:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserProfilePage(),
                      ),
                    );
                  },
                  child: const Text('Hồ sơ người dùng (State phức tạp)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AsyncDataPage(),
                      ),
                    );
                  },
                  child: const Text('Dữ liệu bất đồng bộ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
