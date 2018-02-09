import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'src/widgets/setup.dart';
import 'src/widgets/reader.dart';
import 'src/widgets/histogram.dart';
import 'src/models/reader_state.dart';
import 'src/store/reducer.dart';
import 'src/navigation.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final store = new Store<ReaderState>(reduceAnything,
      initialState: new ReaderState('', -1, 0.0, 0.0, null, []));

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'Language Reader',
        theme: new ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
          // counter didn't reset back to zero; the application is not restarted.
          primarySwatch: Colors.blueGrey,
        ),
        navigatorKey: navigatorKey,
        routes: {
          readerRoute: (context) => new Reader(store: store),
          histogramRoute: (context) => new Histogram()
        },
        home: new MySetupPage(),
      ),
    );
  }
}
