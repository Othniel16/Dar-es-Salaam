import 'package:dar_es_salaam/screens/home/intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:dar_es_salaam/shared/barrier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var savedThemeMode = await AdaptiveTheme.getThemeMode();
  int lastAppTheme = await SharedPreferencesHelper.getLastAppTheme();
  runApp(MyApp(
    savedThemeMode: savedThemeMode,
    lastAppTheme: lastAppTheme,
  ));
}

class MyApp extends StatelessWidget {
  final savedThemeMode;
  final lastAppTheme;

  const MyApp({Key key, @required this.savedThemeMode, this.lastAppTheme})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<AppUser>.value(
          value: AuthService().user,
        ),
        ChangeNotifierProvider<BookProvider>(
          create: (context) => BookProvider(lastAppTheme, savedThemeMode),
        )
      ],
      child: AdaptiveTheme(
        initial: savedThemeMode ?? AdaptiveThemeMode.light,
        light: ThemeData.light().copyWith(
          brightness: Brightness.light,
          textSelectionColor: Colors.black,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepOrange,
          ),
          appBarTheme: AppBarTheme(
            brightness: Brightness.light,
            color: Colors.transparent,
            textTheme: Theme.of(context).textTheme,
            elevation: 0.0,
          ),
        ),
        dark: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Color(0xFF121212),
            brightness: Brightness.dark,
            textSelectionColor: Colors.white,
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.tealAccent,
            ),
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
              color: Colors.transparent,
              textTheme: AppBarTheme.of(context).textTheme,
              elevation: 0.0,
            )),
        builder: (light, dark) => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Splash(),
          theme: light,
          darkTheme: dark,
        ),
      ),
    );
  }
}
