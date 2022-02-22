import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';

import 'db.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Softtrack Здоровье'),
      routes: {
        '/main': (context) => const MyHomePage(
          title: 'Softtrack здоровье'
        ),
        '/active': (context) => const ActiveActivity(),
        '/walk': (context) => const WalkActivity(),
        '/exercise/add': (context) => const AddExerciseActivity(),
        '/exercise/list': (context) => const ExercisesListActivity(),
        '/exercise': (context) => const ExerciseActivity(),
        '/food/record': (context) => const RecordFoodActivity(),
        '/food/add': (context) => const AddFoodItemActivity(),
        '/food/history': (context) => const FoodHistoryActivity(),
        '/food': (context) => const FoodActivity(),
        '/sleep/record': (context) => const RecordSleepActivity(),
        '/sleep': (context) => const SleepActivity(),
        '/body': (context) => const BodyActivity(),
        '/water': (context) => const WaterActivity()
      }
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {

  late DatabaseHandler handler;
  int currentTab = 0;
  int glassesCount = 0;
  late Color removeGlassesBtnColor;
  Color disabledGlassesBtnColor = Color.fromARGB(127, 150, 150, 150);
  Color enabledGlassesBtnColor = Color.fromARGB(255, 150, 150, 150);
  var contextMenuBtns = {
    'Управление элементами',
    'Для вас',
    'События',
    'Уведомления',
    'Настр.',
  };

  /*
  sdk не позволяет использовать педометр
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  */
  String _steps = '0';

  void addGlass() {
    setState(() {
      removeGlassesBtnColor = enabledGlassesBtnColor;
      glassesCount++;
    });
  }

  void removeGlass() {
    bool isGlassesCountEmpty = glassesCount <= 0;
    bool isGlassesCountNotEmpty = !isGlassesCountEmpty;
    if (isGlassesCountNotEmpty) {
      setState(() {
        glassesCount--;
        isGlassesCountEmpty = glassesCount <= 0;
        if (isGlassesCountEmpty) {
          // делаем кнопку disabled
          removeGlassesBtnColor = Color.fromARGB(127, 150, 150, 150);
        }
      });
    }
  }

  void setContextMenu(tabIndex) {
    bool isMainPageActivity = tabIndex == 0;
    bool isTogetherPageActivity = tabIndex == 1;
    bool isFitnesPageActivity = tabIndex == 2;
    bool isMyPageActivity = tabIndex == 3;
    if (isMainPageActivity) {
      setState(() {
        contextMenuBtns = {
          'Управление элементами',
          'Для вас',
          'События',
          'Уведомления',
          'Настр.',
        };
      });
    } else if (isTogetherPageActivity) {
      setState(() {
        contextMenuBtns = {
          'Для вас',
          'События',
          'Уведомления',
          'Настр.',
        };
      });
    } else if (isFitnesPageActivity) {
      setState(() {
        contextMenuBtns = {
          'Направления фитнеса',
          'Журнал программы',
          'Для вас',
          'События',
          'Уведомления',
          'Настр.',
        };
      });
    } else if (isMyPageActivity) {
      setState(() {
        contextMenuBtns = {
          'Для вас',
          'События',
          'Уведомления',
          'Настр.',
        };
      });
    }
  }

  /*
  sdk не позволяет использовать pedometer
  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }
  */

  addFoodRecord(context) {
    Navigator.pushNamed(
        context,
        '/food',
        arguments: {
          'isAddFoodRecord': true
        }
    );
  }

  addSleepRecord(context) {
    Navigator.pushNamed(context, '/sleep/record');
  }

  @override
  initState() {
    super.initState();
    removeGlassesBtnColor = enabledGlassesBtnColor;
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
    /*
    sdk не позволяет использовать pedometer
    initPlatformState();
    */

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<String>(
              itemBuilder: (BuildContext context) {
                return contextMenuBtns.map((String choice) {
                  return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice)
                  );
                }).toList();
              },
            )
          ],
          bottom: TabBar(
            onTap: (index) {
              print('currentTabIndex: ${index}');
              setState(() {
                currentTab = index;
              });
              setContextMenu(currentTab);
            },
            tabs: <Widget>[
              Tab(
                  text: 'Главная'
              ),
              Tab(
                  text: 'Together'
              ),
              Tab(
                  text: 'Фитнес'
              ),
              Tab(
                  text: 'Моя стр.'
              ),
              Tab(
                  text: 'Database inspector'
              )
            ]
          )
        ),
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 225, 225, 225)
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/active');
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15
                          ),
                          padding: EdgeInsets.all(
                              15
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255)
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  )
                                ]
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 15
                                            ),
                                            child: Text(
                                              'Активность',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20
                                              )
                                            )
                                          ),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 10
                                                    ),
                                                    child: Column(
                                                        children: [
                                                          Icon(
                                                              Icons.directions_walk,
                                                              color: Color.fromARGB(255, 0, 150, 0)
                                                          ),
                                                          Text(
                                                              '0'
                                                          )
                                                        ]
                                                    )
                                                ),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 10
                                                    ),
                                                    child: Column(
                                                        children: [
                                                          Icon(
                                                              Icons.timer,
                                                              color: Color.fromARGB(255, 0, 0, 255)
                                                          ),
                                                          Text(
                                                              '0'
                                                          )
                                                        ]
                                                    )
                                                ),
                                                Container(
                                                    margin: EdgeInsets.symmetric(
                                                        horizontal: 10
                                                    ),
                                                    child: Column(
                                                        children: [
                                                          Icon(
                                                              Icons.fireplace,
                                                              color: Color.fromARGB(255, 255, 0, 0)
                                                          ),
                                                          Text(
                                                              '0'
                                                          )
                                                        ]
                                                    )
                                                )
                                              ]
                                          )
                                        ]
                                    ),
                                    Image.network(
                                        'https://cdn4.iconfinder.com/data/icons/medical-115/60/medical-flat-098-heart-beat-128.png',
                                        width: 65
                                    )
                                  ]
                              )
                            ]
                          )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/walk');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                          ),
                          padding: EdgeInsets.all(
                              15
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.remove_circle,
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      )
                                    ]
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Шаги',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                          )
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              child: Text(
                                                _steps,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold
                                                )
                                              )
                                            ),
                                            Text(
                                              '/6000'
                                            )
                                          ]
                                        )
                                      ]
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '0%'
                                        )
                                      ]
                                    )
                                  ]
                                )
                              ]
                          )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/exercise');
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                            15
                          ),
                          margin: EdgeInsets.symmetric(
                              vertical: 15
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  )
                                ]
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                  Text(
                                    'Упражнение',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                  Text(
                                    'Посмотреть журнал',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 150, 150, 150)
                                      )
                                  )
                                ]
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                        Color.fromARGB(255, 255, 255, 255)
                                      ),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100.0),
                                          side: BorderSide(
                                            color: Color.fromARGB(255, 150, 150, 150)
                                          )
                                        )
                                      ),
                                      fixedSize: MaterialStateProperty.all<Size>(
                                        Size(
                                          45.0,
                                          45.0
                                        )
                                      )
                                    ),
                                    onPressed: () {
                                      handler.addNewExerciseRecord('Ходьба', '22.11.2000', '00:00:00');
                                    },
                                    child: Icon(
                                      Icons.directions_walk
                                    )
                                  ),
                                  TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Color.fromARGB(255, 255, 255, 255)
                                          ),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                  side: BorderSide(
                                                      color: Color.fromARGB(255, 150, 150, 150)
                                                  )
                                              )
                                          ),
                                          fixedSize: MaterialStateProperty.all<Size>(
                                              Size(
                                                  45.0,
                                                  45.0
                                              )
                                          )
                                      ),
                                      onPressed: () {
                                        handler.addNewExerciseRecord('Бег', '22.11.2000', '00:00:00');
                                      },
                                      child: Icon(
                                          Icons.directions_run
                                      )
                                  ),
                                  TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Color.fromARGB(255, 255, 255, 255)
                                          ),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                  side: BorderSide(
                                                      color: Color.fromARGB(255, 150, 150, 150)
                                                  )
                                              )
                                          ),
                                          fixedSize: MaterialStateProperty.all<Size>(
                                              Size(
                                                  45.0,
                                                  45.0
                                              )
                                          )
                                      ),
                                      onPressed: () {
                                        handler.addNewExerciseRecord('Велоспорт', '22.11.2000', '00:00:00');
                                      },
                                      child: Icon(
                                          Icons.bike_scooter
                                      )
                                  ),
                                  TextButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Color.fromARGB(255, 255, 255, 255)
                                          ),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0),
                                                  side: BorderSide(
                                                      color: Color.fromARGB(255, 150, 150, 150)
                                                  )
                                              )
                                          ),
                                          fixedSize: MaterialStateProperty.all<Size>(
                                              Size(
                                                  45.0,
                                                  45.0
                                              )
                                          )
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/exercise/list');
                                      },
                                      child: Icon(
                                        Icons.list
                                      )
                                  )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/food',
                            arguments: {
                              'isAddFoodRecord': false
                            }
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          padding: EdgeInsets.all(
                            25
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  )
                                ]
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Еда',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                        )
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 10
                                            ),
                                            child: Text(
                                              '0',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28
                                              )
                                            )
                                          ),
                                          Text(
                                            '/1779 ккал'
                                          )
                                        ]
                                      )
                                    ]
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      addFoodRecord(context);
                                      // handler.addNewFoodRecord('Завтрак');
                                    },
                                    child: Text(
                                      'Запись'
                                    ),
                                    style: ButtonStyle(
                                      foregroundColor: MaterialStateProperty.all<Color>(
                                        Color.fromARGB(255, 0, 0, 0)
                                      ),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(100.0),
                                          side: BorderSide(
                                            color: Color.fromARGB(255, 150, 150, 150)
                                          )
                                        )
                                      ),
                                      fixedSize: MaterialStateProperty.all<Size>(
                                        Size(
                                          125.0,
                                          45.0
                                        )
                                      )
                                    )
                                 )
                                ]
                              )
                            ]
                          )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/sleep');
                        },
                        child: Container(
                          padding: EdgeInsets.all(
                              25
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255)
                          ),
                          child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.remove_circle,
                                        color: Color.fromARGB(255, 255, 0, 0),
                                      )
                                    ]
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Сон',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20
                                          )
                                        ),
                                        Text(
                                            'Как вам спалось'
                                        )
                                      ]
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // handler.addNewSleepRecord('00', '00', '22.11.2000');
                                        addSleepRecord(context);
                                      },
                                      child: Text(
                                        'Запись'
                                      ),
                                      style: ButtonStyle(
                                        foregroundColor: MaterialStateProperty.all<Color>(
                                          Color.fromARGB(255, 0, 0, 0)
                                        ),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100.0),
                                            side: BorderSide(
                                              color: Color.fromARGB(255, 150, 150, 150)
                                            )
                                          )
                                        ),
                                        fixedSize: MaterialStateProperty.all<Size>(
                                          Size(
                                            125.0,
                                            45.0
                                          )
                                        )
                                      )
                                    )
                                  ]
                                )
                              ]
                          )
                        )
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/body');
                          },
                          child: Container(
                            padding: EdgeInsets.all(
                                15
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 15
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 255, 255)
                            ),
                            child: Column(
                                children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.remove_circle,
                                          color: Color.fromARGB(255, 255, 0, 0),
                                        )
                                      ]
                                  ),
                                  Container(
                                      child: Text(
                                          'Состав тела',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20
                                          )
                                      ),
                                      margin: EdgeInsets.symmetric(
                                          vertical: 15
                                      )
                                  ),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10
                                            ),
                                            child: Column(
                                                children: [
                                                  Icon(
                                                      Icons.home,
                                                      color: Color.fromARGB(255, 0, 150, 0)
                                                  ),
                                                  Text(
                                                      '0',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10
                                            ),
                                            child: Column(
                                                children: [
                                                  Icon(
                                                      Icons.circle,
                                                      color: Colors.brown
                                                  ),
                                                  Text(
                                                      '0',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24
                                                      )
                                                  )
                                                ]
                                            )
                                        ),
                                        Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10
                                            ),
                                            child: Column(
                                                children: [
                                                  Icon(
                                                      Icons.sports_rugby,
                                                      color: Color.fromARGB(255, 0, 0, 255)
                                                  ),
                                                  Text(
                                                      '0',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24
                                                      )
                                                  )
                                                ]
                                            )
                                        )
                                      ]
                                  )
                                ]
                            )
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/water');
                        },
                        child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(
                          15
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.remove_circle,
                                  color: Color.fromARGB(255, 255, 0, 0),
                                )
                              ]
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      children: [
                                        Text(
                                          'Вода',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18
                                          )
                                        ),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$glassesCount',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 28
                                              )
                                            ),
                                            Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 5
                                                ),
                                                child: Text(
                                                  'стак.'
                                                )
                                            )
                                          ]
                                        )
                                      ]
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: TextButton(

                                          onPressed: () {
                                            removeGlass();
                                          },
                                          child: Icon(
                                            Icons.remove
                                          ),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100.0),
                                                side: BorderSide(
                                                  color: removeGlassesBtnColor
                                                )
                                              )
                                            ),
                                            fixedSize: MaterialStateProperty.all<Size>(
                                              Size(
                                                45.0,
                                                45.0
                                              )
                                            ),
                                            foregroundColor: MaterialStateProperty.all<Color>(
                                              removeGlassesBtnColor
                                            )
                                          )
                                        ),
                                        margin: EdgeInsets.all(
                                          15
                                        )
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          addGlass();
                                        },
                                        child: Icon(
                                            Icons.add
                                        ),
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.0),
                                              side: BorderSide(
                                                color: Color.fromARGB(255, 150, 150, 150)
                                              )
                                            )
                                          ),
                                          fixedSize: MaterialStateProperty.all<Size>(
                                            Size(
                                              45.0,
                                              45.0
                                            )
                                          ),
                                          foregroundColor: MaterialStateProperty.all<Color>(
                                            Color.fromARGB(255, 150, 150, 150)
                                          )
                                        )
                                      )
                                    ]
                                  )
                                ]
                            )
                          ]
                        )
                      )
                    )
                  ]
                )
              )
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 225, 225, 225)
              ), 
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.network(
                        'https://cdn2.iconfinder.com/data/icons/flat-seo-web-ikooni/128/flat_seo-40-256.png',
                        width: 50,
                        height: 50
                      ),
                      Column(
                        children: [
                          Text(
                            'glebdyakov',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          ),
                          Text(
                            'Уровень 1',
                            style: TextStyle(
                              fontSize: 20
                            )
                          )
                        ]
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_alarm');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined
                            ),
                            Text(
                                'Задачи'
                            )
                          ]
                        ),
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 0, 0, 0)
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 200, 200, 200)
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Colors.transparent
                                    )
                                )
                            )
                        )
                      )
                    ]
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 15
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255)  
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Друзья',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                              )
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 5
                              ),
                              child: Text(
                                '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color.fromARGB(255, 0, 100, 0)
                                )
                              )
                            )
                          ]
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_alarm');
                          },
                          child: Text(
                            'Добавить'
                          ),
                          style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 0, 0, 0)
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 200, 200, 200)
                              ),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                    color: Colors.transparent
                                  )
                                )
                              )
                          )
                        )
                      ]
                    )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 15
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: 15
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255)
                    ),
                    child: Column(
                      children: [
                        Text(
                          '#Stronger Together',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18 
                          )
                        ),
                        Text(
                          'Присоединяйтесь к соревнованию, чтобы подде...'
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Участники',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24
                                  )
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/add_alarm');
                                  },
                                  child: Text(
                                      'Присоединиться'
                                  ),
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 0, 0, 0)
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 200, 200, 200)
                                    ),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(
                                          color: Colors.transparent
                                        )
                                      )
                                    )
                                  )
                                )
                              ]
                            ),
                            Image.network(
                              'https://live.staticflickr.com/7050/8690945256_35b26a6738_b.jpg',
                              width: 100,
                              height: 100
                            )
                          ]
                        ),
                      ]
                    )
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255)  
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 15
                    ),
                    margin: EdgeInsets.symmetric(
                        vertical: 15
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Спа февраль',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                          )
                        ),
                        Text(
                          'Присоединяйтесь к соревнованию, чтобы\nподдерживать форму вместе с другими.'
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Участники',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24
                                  )
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/add_alarm');
                                  },
                                  child: Text(
                                    'Присоединиться'
                                  ),
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 0, 0, 0)
                                    ),
                                    backgroundColor: MaterialStateProperty.all(
                                      Color.fromARGB(255, 200, 200, 200)
                                    ),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                        side: BorderSide(
                                          color: Colors.transparent
                                        )
                                      )
                                    )
                                  )
                                )
                              ]
                            ),
                            Image.network(
                              'https://live.staticflickr.com/7050/8690945256_35b26a6738_b.jpg',
                              width: 100,
                              height: 100
                            )
                          ]
                        ),
                      ]
                    )
                  )
                ]
              )
            ),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 225, 225, 225)
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255)
                      ),
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Новшества',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                )
                              ),
                              Icon(
                                Icons.chevron_right
                              )
                            ]
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Image.network(
                                      'https://www.ambal.ru/32547104475.jpg',
                                      width: 100,
                                    ),
                                    Text(
                                      'Упражнение для сжигания ...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                    Text(
                                        '1 неделя'
                                    ),
                                  ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                ),
                                Column(
                                    children: [
                                      Image.network(
                                        'https://www.ambal.ru/32547104475.jpg',
                                        width: 100,
                                      ),
                                      Text(
                                          'Упражнение для сжигания ...',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold
                                          )
                                      ),
                                      Text(
                                          '1 неделя'
                                      ),
                                    ]
                                )
                              ]
                            )
                          )
                        ]
                      )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Фитнес для женщин',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Похудение',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Наращивание мышечной массы',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Работа над балансом',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Тренировка на выносливость',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Бег',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'Майндфулнес',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              ),
                                              Text(
                                                  'Упражнение для сжигания ...',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold
                                                  )
                                              ),
                                              Text(
                                                  '1 неделя'
                                              ),
                                            ]
                                        )
                                      ]
                                  )
                              )
                            ]
                        )
                    ),
                    Container(
                        margin: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255)
                        ),
                        padding: EdgeInsets.all(15),
                        child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        'По поставщику',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20
                                        )
                                    ),
                                    Icon(
                                        Icons.chevron_right
                                    )
                                  ]
                              ),
                              SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: [
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                        Column(
                                            children: [
                                              Image.network(
                                                'https://www.ambal.ru/32547104475.jpg',
                                                width: 100,
                                              )
                                            ]
                                        ),
                                      ]
                                  )
                              )
                            ]
                        )
                    )
                  ]
                )
              )
            ),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 225, 225, 225)
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(15.0),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Image.network(
                                'https://cdn3.iconfinder.com/data/icons/generic-avatars/128/avatar_portrait_man_male-256.png',
                                width: 100,
                                height: 100
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add_alarm');
                                },
                                child: Text(
                                    'Изменить'
                                ),
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 0, 0, 0)
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 200, 200, 200)
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(
                                        color: Colors.transparent
                                      )
                                    )
                                  )
                                )
                              )
                            ]
                          ),
                          Text(
                            'glebdyakov',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold
                            )
                          )
                        ],
                      )
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Сводка за неделю',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            )
                          ),
                          Text(
                            '7-13 февраля'
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Ср. время активности'
                              ),
                              Text(
                                '-----------------------------'
                              ),
                              Text(
                                '49',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              Text(
                                'мин.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              )
                            ]
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                  'Среднее потребление каллорий'
                              ),
                              Text(
                                  '----------------'
                              ),
                              Text(
                                '50',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              Text(
                                  'ккал',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              )
                            ]
                          )
                        ],
                      )
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Личные рекорды',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.left
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    size: 48.0
                                  ),
                                  Text(
                                    '2475'
                                  ),
                                  Text(
                                      'шаг.'
                                  ),
                                  Text(
                                      'Максимум шагов'
                                  )
                                ]
                              ),
                              Column(
                                  children: [
                                    Icon(
                                        Icons.stairs,
                                        size: 48.0
                                    ),
                                    Text(
                                        ''
                                    ),
                                    Text(
                                        ''
                                    ),
                                    Text(
                                        'Больше всего\nэтажей',
                                      textAlign: TextAlign.center,
                                    )
                                  ]
                              ),
                              Column(
                                  children: [
                                    Icon(
                                        Icons.timer,
                                        size: 48.0
                                    ),
                                    Text(
                                        '312'
                                    ),
                                    Text(
                                        'мин.'
                                    ),
                                    Text(
                                        'Длительность'
                                    )
                                  ]
                              )
                            ]
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                    children: [
                                      Icon(
                                          Icons.fireplace,
                                          size: 48.0
                                      ),
                                      Text(
                                          '3254'
                                      ),
                                      Text(
                                          'ккал.'
                                      ),
                                      Text(
                                          'Потеряно калорий'
                                      )
                                    ]
                                ),
                                Column(
                                    children: [
                                      Icon(
                                          Icons.location_on,
                                          size: 48.0
                                      ),
                                      Text(
                                          ''
                                      ),
                                      Text(
                                          ''
                                      ),
                                      Text(
                                        'Расстояние',
                                        textAlign: TextAlign.center,
                                      )
                                    ]
                                ),
                                Column(
                                    children: [
                                      Icon(
                                          Icons.height,
                                          size: 48.0
                                      ),
                                      Text(
                                          ''
                                      ),
                                      Text(
                                          '.'
                                      ),
                                      Text(
                                          'Прирост высоты'
                                      )
                                    ]
                                )
                              ]
                          ),
                          Text(
                            'Всего шагов 3993 (после присоединения 5 февраля)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 150, 150, 150)
                            )
                          )
                        ],
                      )
                    ),
                    Container(
                      margin: EdgeInsets.all(15.0),
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Значки',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add_alarm');
                                },
                                child: Icon(
                                  Icons.chevron_right
                                ),
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    Color.fromARGB(255, 0, 0, 0)
                                  )
                                )
                              )
                            ]
                          ),
                          SingleChildScrollView(
                            child: Container(
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/flat-pack-1/64/Trophy-256.png',
                                          width: 75
                                      ),
                                      Text(
                                        'Упражнение',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '11 февр.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                  ),
                                  Column(
                                    children: [
                                      Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/flat-pack-1/64/Trophy-256.png',
                                          width: 75
                                      ),
                                      Text(
                                        'Упражнение',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '11 февр.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                  ),
                                  Column(
                                    children: [
                                      Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/flat-pack-1/64/Trophy-256.png',
                                          width: 75
                                      ),
                                      Text(
                                        'Упражнение',
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '11 февр.',
                                        textAlign: TextAlign.center,
                                      ),
                                    ]
                                  )
                                ],
                              )
                            )
                          )
                        ],
                      )
                    )
                  ]
                )
              )
            ),
            Column(
              children: <Widget>[
                TextButton(
                    child: Text(
                        'Database inspector'
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DatabaseList()));
                    }
                )
              ],
            )
          ]
        )
      )
    );
  }
}

class WaterActivity extends StatefulWidget {

  const WaterActivity({Key? key}) : super(key: key);

  @override
  State<WaterActivity> createState() => _WaterActivityState();

}

class _WaterActivityState extends State<WaterActivity> {

  int glassesCount = 0;
  late Color removeGlassesBtnColor;
  Color disabledGlassesBtnColor = Color.fromARGB(127, 150, 150, 150);
  Color enabledGlassesBtnColor = Color.fromARGB(255, 150, 150, 150);
  int mlsPerGlass = 250;
  var contextMenuBtns = {'Установить норму', 'Аксессуары'};

  void removeGlass() {
    bool isGlassesCountEmpty = glassesCount <= 0;
    bool isGlassesCountNotEmpty = !isGlassesCountEmpty;
    if (isGlassesCountNotEmpty) {
      setState(() {
        glassesCount--;
        isGlassesCountEmpty = glassesCount <= 0;
        if (isGlassesCountEmpty) {
          // делаем кнопку disabled
          removeGlassesBtnColor = Color.fromARGB(127, 150, 150, 150);
        }
      });
    }
  }

  void addGlass() {
    setState(() {
      removeGlassesBtnColor = enabledGlassesBtnColor;
      glassesCount++;
    });
  }

  String computeGlassesMls() {
    int glassesCountMls = glassesCount * mlsPerGlass;
    String updatedGlassesCountMls = '$glassesCountMls';
    return updatedGlassesCountMls;
  }

  @override
  initState() {
    super.initState();
    removeGlassesBtnColor = enabledGlassesBtnColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Вода'
        ),
        actions: <Widget>[
          GestureDetector(
            child: PopupMenuButton<String>(
              icon: Icon(
                  Icons.bar_chart
              ),
              itemBuilder: (BuildContext context) {
                return [];
              }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return contextMenuBtns.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice)
                );
              }).toList();
            },
          )
        ]
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              25
            ),
            margin: EdgeInsets.symmetric(
              vertical: 25
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            child: Column(
              children: [
                Text(
                  'Сегодня',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
                Container(
                  child: Image.asset(
                    'assets/images/glass_calculator.png',
                    width: 100,
                    height: 100
                  ),
                  margin: EdgeInsets.symmetric(
                    vertical: 25
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 0, 0)
                        )
                      ),
                      onPressed: () {
                        removeGlass();
                      },
                      child: Text(
                        '-'
                      )
                    ),
                    Text(
                      '$glassesCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 48
                      )
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 0, 0)
                        )
                      ),
                      onPressed: () {
                        addGlass();
                      },
                      child: Text(
                        '+'
                      )
                    )
                  ]
                ),
                Text(
                  'стак.'
                ),
                Text(
                  '(${computeGlassesMls()} мл)'
                ),
                Text(
                  'Отслеживайте объем потребляемой воды'
                )
              ]
            )
          )
        ]
      )
    );
  }

}

class BodyActivity extends StatefulWidget {

  const BodyActivity({Key? key}) : super(key: key);

  @override
  State<BodyActivity> createState() => _BodyActivityState();

}

class _BodyActivityState extends State<BodyActivity> {

  late DatabaseHandler handler;
  List<Column> bodyRecords = [];
  var contextMenuBtns = {
    'Установить норму',
    'Приостановить подсчет шагов',
    'О разделе \"Шаги\"'
  };
  String lastBodyRecordWeight = '';
  String lastBodyRecordFat = '';
  String lastBodyRecordMusculature = '';

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  void addBodyRecord(BodyRecord record) {
    double bodyRecordWeight = record.weight;
    int bodyRecordFat = record.fat;
    int bodyRecordMusculature = record.musculature;
    int bodyRecordsIndex = bodyRecords.length;
    Column bodyRecord = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${bodyRecordWeight} кг'
            ),
            Text(
              '${bodyRecordFat} %'
            ),
            Text(
              '${bodyRecordMusculature} кг'
            )
          ]
        ),
        Text(
          '10:00'
        ),
        Divider(
          thickness: 1,
        )
      ]
    );
    bodyRecords.add(bodyRecord);
    // setState(() {
      lastBodyRecordWeight = '0';
      lastBodyRecordFat = '0';
      lastBodyRecordMusculature = '0';
    // });
  }

  @override
  Widget build(BuildContext context) {

    // addBodyRecord();
    // addBodyRecord();
    // addBodyRecord();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Состав тела'
        ),
        actions: <Widget>[
          GestureDetector(
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.bar_chart
              ),
              itemBuilder: (BuildContext context) {
                return [];
              }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return contextMenuBtns.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice)
                );
              }).toList();
            },
          )
        ]
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: 15
                ),
                padding: EdgeInsets.all(
                    15
                ),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: Column(
                  children: [
                    Text(
                      '11 февр., 09:08'
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            children: [
                              Text(
                                  'Вес',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 0, 175, 0)
                                  )
                              ),
                              Text(
                                  '${lastBodyRecordWeight} кг',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28
                                  )
                              )
                            ]
                        ),
                        Column(
                            children: [
                              Text(
                                  'Телесный жир'
                              ),
                              Text(
                                  '${lastBodyRecordFat} %',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28
                                  )
                              )
                            ]
                        ),
                        Column(
                            children: [
                              Text(
                                  'Скелетн.\nмускулат.'
                              ),
                              Text(
                                  '${lastBodyRecordMusculature} кг',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28
                                  )
                              )
                            ]
                        )
                      ]
                    ),
                    Divider(
                      thickness: 1
                    ),
                    Text(
                      'Чтобы рассчитать ИМТ укажите в профиле свой рост.',
                      textAlign: TextAlign.center
                    ),
                    Text(
                      'Редактировать профиль',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Divider(
                      thickness: 1
                    )
                  ]
                )
              ),
              Container(
                margin: EdgeInsets.symmetric(
                  vertical: 15
                ),
                padding: EdgeInsets.all(
                  15
                ),
                width: 1000,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: FutureBuilder(
                  future: this.handler.retrieveBodyRecords(),
                  builder: (BuildContext context, AsyncSnapshot<List<BodyRecord>> snapshot) {
                    int snapshotsCount = 0;
                    if (snapshot.data != null) {
                      snapshotsCount = snapshot.data!.length;
                      bodyRecords = [];
                      for (int snapshotIndex = 0; snapshotIndex <
                          snapshotsCount; snapshotIndex++) {
                        addBodyRecord(snapshot.data!.elementAt(snapshotIndex));
                      }
                    }
                    if (snapshot.hasData) {
                      return Column(
                          children: [
                            Container(
                                height: 250,
                                child: SingleChildScrollView(
                                    child: Column(
                                        children: bodyRecords
                                    )
                                )
                            )
                          ]
                      );
                    } else {
                      return Column(

                      );
                    }
                    return Column(

                    );
                  }
                )
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 200, 200, 200)
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(
                        color: Colors.transparent
                      )
                    )
                  )
                ),
                child: Text(
                  'Запись'
                ),
                onPressed: () {
                  handler.addNewBodyRecord('', 0, 0, 0.0, '');
                }
              )
            ]
          )
        )
      )
    );
  }

}

class SleepActivity extends StatefulWidget {

  const SleepActivity({Key? key}) : super(key: key);

  @override
  State<SleepActivity> createState() => _SleepActivityState();

}

class _SleepActivityState extends State<SleepActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Сон'
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                  15
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: Column(
                  children: [
                    Text(
                      'Сегодня'
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Часов: '
                        ),
                        Text(
                          '0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(
                          ', '
                        ),
                        Text(
                          'минут: '
                        ),
                        Text(
                          '0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(
                          '.'
                        )
                      ]
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 15
                      ),
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 225, 225, 225)
                      )
                    )
                  ]
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text(
                      'Добавить запись'
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/sleep/record');
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 175, 175, 175)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      ),
                    )
                  )
                ]
              )
            ]
          )
        )
      )
    );
  }

}

class FoodActivity extends StatefulWidget {

  const FoodActivity({Key? key}) : super(key: key);

  @override
  State<FoodActivity> createState() => _FoodActivityState();

}

class _FoodActivityState extends State<FoodActivity> {

  late DatabaseHandler handler;

  var contextMenuBtns = {
    'Устновить норму',
    'Мое питание',
    'О \"Питании и диете\"',
  };

  List<String> foodTypes = [
    'Завтрак',
    'Обед',
    'Ужин',
    'Утренний перекус',
    'Дневной перекус',
    'Вечерний перекус'
  ];

  FoodType selectedFoodType = FoodType.none;

  List<Widget> foodRecords = [];

  setFoodType(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Прием пищи'),
        content: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.breakfast,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      // setState(() {
                        selectedFoodType = value!;
                      // });
                    }
                  ),
                  Text(
                    'Завтрак'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.lanch,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value!;
                      });
                    }
                  ),
                  Text(
                    'Обед'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.dinner,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value!;
                      });
                    }
                  ),
                  Text(
                    'Ужин'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.morningMeal,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value!;
                      });
                    }
                  ),
                  Text(
                    'Утренний перекус'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.dayMeal,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value!;
                      });
                    }
                  ),
                  Text(
                      'Дневной перекус'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<FoodType>(
                    value: FoodType.eveningMeal,
                    groupValue: selectedFoodType,
                    onChanged: (value) {
                      setState(() {
                        selectedFoodType = value!;
                      });
                    }
                  ),
                  Text(
                    'Вечерний перекус'
                  )
                ]
              ),
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              int foodTypeIndex = selectedFoodType.index - 1;
              String foodType = foodTypes[foodTypeIndex];
              Navigator.pushNamed(
                context,
                '/food/record',
                arguments: {
                  'foodType': foodType
                }
              );
            },
            child: const Text('Готово')
          )
        ]
      )
    );
  }

  addFoodRecord(FoodRecord record) {
    String foodRecordType = record.type;
    Container foodRecord = Container(
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: 15
            ),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 200, 200, 200),
              borderRadius: BorderRadius.circular(100.0)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    '0'
                ),
                Text(
                    'Ккал'
                )
              ]
            )
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Divider(
                thickness: 1.0,
                color: Color.fromARGB(255, 150, 150, 150)
              ),
              Text(
                foodRecordType
              ),
              Text(
                '-------'
              )
            ]
          )
        ]
      ),
      margin: EdgeInsets.symmetric(
        vertical: 15
      )
    );
    foodRecords.add(foodRecord);
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    /*
    не работает автоматическое открытие диалога
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    if (arguments != null) {
      bool isAddFoodRecord = arguments['isAddFoodRecord'];
      print('$isAddFoodRecord');
      if (isAddFoodRecord) {
        setFoodType(context);
      }
    }
    */

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Еда'
        ),
        actions: <Widget>[
          GestureDetector(
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.bar_chart
              ),
              itemBuilder: (BuildContext context) {
                return [];
              }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return contextMenuBtns.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice)
                );
              }).toList();
            },
          )
        ]
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                    15
                ),
                margin: EdgeInsets.symmetric(
                    vertical: 15
                ),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: null
              ),
              Container(
                padding: EdgeInsets.all(
                  15
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: Column(
                  children: [
                    Text(
                      'Сегодня',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 5
                          ),
                          child: Text(
                            'Ккал',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            )
                          )
                        )
                      ]
                    ),
                    // assets/images/food_logo
                    Image.asset(
                      'assets/images/food_logo.png',
                      width: 100,
                      height: 100,
                    ),
                    FutureBuilder(
                      future: this.handler.retrieveFoodRecords(),
                      builder: (BuildContext context, AsyncSnapshot<List<FoodRecord>> snapshot) {
                        int snapshotsCount = 0;
                        if (snapshot.data != null) {
                          snapshotsCount = snapshot.data!.length;
                          foodRecords = [];
                          for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                            addFoodRecord(snapshot.data!.elementAt(snapshotIndex));
                          }
                        }
                        if (snapshot.hasData) {
                          return Column(
                            children: [
                              Container(
                                  height: 250,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: foodRecords
                                    )
                                  )
                              )
                            ]
                          );
                        } else {
                          return Text(
                            'Отслеживание питания поможет придерживаться\nздоровой сбалансированной диеты',
                            textAlign: TextAlign.center
                          );
                        }
                        return Text(
                          'Отслеживание питания поможет придерживаться\nздоровой сбалансированной диеты',
                          textAlign: TextAlign.center
                        );
                      }
                    )
                  ]
                )
              ),
              TextButton(
                child: Text(
                  'Запись'
                ),
                onPressed: () {
                  setFoodType(context);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 175, 175, 175)
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      side: BorderSide(
                        color: Color.fromARGB(255, 150, 150, 150)
                      )
                    )
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(
                      125.0,
                      45.0
                    )
                  )
                )
              )
            ]
          )
        )
      )
    );
  }

}

class ExerciseActivity extends StatefulWidget {

  const ExerciseActivity({Key? key}) : super(key: key);

  @override
  State<ExerciseActivity> createState() => _ExerciseActivityState();

}

class _ExerciseActivityState extends State<ExerciseActivity> {

  late DatabaseHandler handler;

  var contextMenuBtns = {
    'Скрыть автозаписи',
    'Удалить'
  };

  List<Column> exercisesRecords = [];

  void addExerciseRecord(ExerciseRecord record) {
    String exerciseRecordType = record.type;
    String exerciseRecordDatetime = record.datetime;
    String exerciseRecordDuration = record.duration;
    Column exerciseRecord = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$exerciseRecordDatetime',
              style: TextStyle(
                fontWeight: FontWeight.bold
              )
            ),
            Text(
              '$exerciseRecordDuration'
            )
          ]
        ),
        Divider(
          thickness: 1,
          color: Color.fromARGB(255, 150, 150, 150),
        ),
        Row(
          children: [
            Icon(
              Icons.directions_run
            ),
            Text(
              '$exerciseRecordType'
            )
          ]
        ),
        Text(
          '$exerciseRecordDuration'
        ),
        Text(
          '$exerciseRecordDatetime'
        )
      ]
    );
    exercisesRecords.add(exerciseRecord);
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    // addExerciseRecord();
    // addExerciseRecord();
    // addExerciseRecord();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Все упражнения'
        ),
        actions: <Widget>[
          GestureDetector(
            child: PopupMenuButton<String>(
              icon: Icon(
                  Icons.arrow_drop_down
              ),
              itemBuilder: (BuildContext context) {
                return [];
              }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          GestureDetector(
            child: PopupMenuButton<String>(
                icon: Icon(
                    Icons.calendar_today
                ),
                itemBuilder: (BuildContext context) {
                  return [];
                }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          GestureDetector(
            child: PopupMenuButton<String>(
                icon: Icon(
                    Icons.arrow_forward_rounded
                ),
                itemBuilder: (BuildContext context) {
                  return [];
                }
            ),
            onTap: () {
              Navigator.pushNamed(context, '/main');
            }
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return contextMenuBtns.map((String choice) {
                return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice)
                );
              }).toList();
            },
          )
        ]
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(
                  15
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 15
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: Column(
                  children: [
                    Text(
                      '7-13 февр.'
                    ),
                    Text(
                      '00:00:00',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36
                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '3563',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24
                              )
                            ),
                            Container(
                                margin: EdgeInsets.only(
                                  left: 5
                                ),
                                child: Text(
                                  'ккал',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  )
                                )
                            )
                          ]
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 5
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 35
                                ),
                                child: Text(
                                  '9',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24
                                  )
                                )
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  left: 5
                                ),
                                child: Text(
                                  'сеансы',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                  )
                                )
                              )
                            ]
                          )
                        )
                      ]
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 25
                      ),
                      child: FutureBuilder(
                        future: this.handler.retrieveExerciseRecords(),
                        builder: (BuildContext context, AsyncSnapshot<List<ExerciseRecord>> snapshot) {
                          int snapshotsCount = 0;
                          if (snapshot.data != null) {
                            snapshotsCount = snapshot.data!.length;
                            exercisesRecords = [];
                            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                              addExerciseRecord(snapshot.data!.elementAt(snapshotIndex));
                            }
                          }
                          if (snapshot.hasData) {
                            return Column(
                              children: [
                                Container(
                                  height: 250,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: exercisesRecords
                                    )
                                  )
                                )
                              ]
                            );
                          } else {
                            return Column(

                            );
                          }
                          return Column(

                          );
                        }
                      )
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

}


class WalkActivity extends StatefulWidget {

  const WalkActivity({Key? key}) : super(key: key);

  @override
  State<WalkActivity> createState() => _WalkActivityState();

}

class _WalkActivityState extends State<WalkActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Шаги'
        ),
        actions: [

        ]
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15
          ),
          padding: EdgeInsets.all(
            15
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255)
          ),
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Text(
                      'Сегодня'
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '0',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24
                          )
                        ),
                        Text(
                          ' шагов',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          )
                        )
                      ]
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 15
                      ),
                      child: LinearProgressIndicator(

                      )
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15
                          ),
                          child: Row(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                )
                              ),
                              Text(
                                ' км',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              )
                            ]
                          )
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15
                          ),
                          child: Row(
                            children: [
                              Text(
                                '0',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                )
                              ),
                              Text(
                                ' км',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              )
                            ]
                          )
                        )
                      ]
                    ),
                    Text(
                      'Данные о шагах не введены'
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

}

class ActiveActivity extends StatefulWidget {

  const ActiveActivity({Key? key}) : super(key: key);

  @override
  State<ActiveActivity> createState() => _ActiveActivityState();

}

class _ActiveActivityState extends State<ActiveActivity> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Активность'
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: 15
          ),
          padding: EdgeInsets.all(
            15
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: Column(
                  children: [
                    Text(
                      'Сегодня'
                    ),
                    Image.asset(
                      'assets/images/food_logo.png',
                      width: 150,
                      height: 150
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Шаги'
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                    Icons.directions_walk,
                                    size: 24
                                ),
                                Container(
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                      )
                                    ),
                                    margin: EdgeInsets.only(
                                        left: 15
                                    )
                                )
                              ]
                            ),
                            Text(
                              '/6000'
                            )
                          ]
                        ),
                        Column(
                          children: [
                            Text(
                                'Время активности'
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 24
                                  ),
                                  Container(
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20
                                      )
                                    ),
                                    margin: EdgeInsets.only(
                                      left: 15
                                    )
                                  )
                                ]
                            ),
                            Text(
                                '/90 мин'
                            )
                          ]
                        ),
                        Column(
                          children: [
                            Text(
                                'Скелетн.\nмускулат.'
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                    Icons.directions_walk,
                                    size: 24
                                ),
                                Container(
                                  child: Text(
                                      '0'
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 15
                                  )
                                )
                              ]
                            ),
                            Text(
                              '/500 ккал'
                            )
                          ]
                        )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Всего сожжено каллорий'
                        ),
                        Text(
                          '********************'
                        ),
                        Text(
                          '666 ккал',
                          style: TextStyle(
                            fontSize: 18
                          )
                        )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Расстояние, пройденное в ходе активностей'
                        ),
                        Text(
                          '*****'
                        ),
                        Text(
                          '0,0 км',
                          style: TextStyle(
                              fontSize: 18
                          )
                        )
                      ]
                    ),
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }

}

class RecordSleepActivity extends StatefulWidget {

  const RecordSleepActivity({Key? key}) : super(key: key);

  @override
  State<RecordSleepActivity> createState() => _RecordSleepActivityState();

}

class _RecordSleepActivityState extends State<RecordSleepActivity> {

  late DatabaseHandler handler;
  String sleepDate = '00.00.0000';
  String sleepDateLabel = 'пн, 21 февр.';
  var weekDayLabels = <String, String>{
    'Monday': 'пн',
    'Tuesday': 'вт',
    'Wednesday': 'ср',
    'Thursday': 'чт',
    'Friday': 'пт',
    'Saturday': 'сб',
    'Sunday': 'вс'
  };
  var monthsLabels = <int, String>{
    0: 'янв.',
    1: 'февр.',
    2: 'мар.',
    3: 'апр.',
    4: 'мая',
    5: 'июн.',
    6: 'июл.',
    7: 'авг.',
    8: 'сен.',
    9: 'окт.',
    10: 'ноя.',
    11: 'дек'
  };

  addSleepRecord(BuildContext context) {
    handler.addNewSleepRecord('00', '00', sleepDate);
    Navigator.pushNamed(context, '/sleep');
  }

  setSleepDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(
        Duration(
          days: 365
        )
      ),
      lastDate: DateTime.now().add(
        Duration(
          days: 365
        )
      )
    );
    setState(() {
      bool isDatePick = pickedDate != null;
      if (isDatePick) {
        showSleepDate(pickedDate);
      }
    });

  }

  showSleepDate(DateTime pickedDate) {
    int pickedDateDay = pickedDate.day;
    int pickedDateMonth = pickedDate.month;
    int pickedDateYear = pickedDate.year;
    sleepDate = '${pickedDateDay}.${pickedDateMonth}.${pickedDateYear}';
    String weekDayKey = DateFormat('EEEE').format(pickedDate);
    String? weekDayLabel = weekDayLabels[weekDayKey];
    String? monthLabel = monthsLabels[pickedDateMonth];
    sleepDateLabel = '${weekDayLabel}, ${pickedDateDay} ${monthLabel}';
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
    DateTime currentDate = DateTime.now();
    showSleepDate(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Записать вручную'
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 15
            ),
            padding: EdgeInsets.all(
              15
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            child: Column(
              children: [
                TextButton(
                  child: Text(
                    sleepDateLabel
                  ),
                  onPressed: () {
                    setSleepDate(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 175, 175, 175)
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 150, 150, 150)
                            )
                        )
                    ),
                    fixedSize: MaterialStateProperty.all<Size>(
                      Size(
                        125.0,
                        45.0
                      )
                    )
                  )
                ),
                Container(
                  width: 250,
                  height: 250,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '8',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24
                      )
                    ),
                    Container(
                      child: Text(
                        'ч',
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        )
                      ),
                      margin: EdgeInsets.only(
                        left: 5
                      )
                    )
                  ]
                ),
                Text(
                'Время сна',
                  style: TextStyle(
                    color: Color.fromARGB(255, 175, 175, 175)
                  )
                )
              ]
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(
                      100.0,
                      45.0
                    )
                  )
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/sleep');
                },
                child: Text(
                  'Отмена'
                )
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(
                      100.0,
                      45.0
                    )
                  )
                ),
                onPressed: () {
                  addSleepRecord(context);
                },
                child: Text(
                  'Сохр.'
                )
              )
            ]
          )
        ]
      )
    );
  }

}

class RecordFoodActivity  extends StatefulWidget {

  const RecordFoodActivity({Key? key}) : super(key: key);

  @override
  State<RecordFoodActivity> createState() => _RecordFoodActivityState();

}

class _RecordFoodActivityState extends State<RecordFoodActivity> {

  late DatabaseHandler handler;

  List<Row> foodItems = [];

  List<bool> foodItemsSelectors = [];

  String initialBtnTitle = 'Проп еду.';

  String foodHistoryBtnTitle = 'Далее';

  String nextBtnTitle = '';

  String foodType = '';

  addFoodItem(FoodItem item) {
    int foodItemIndex = foodItems.length;
    foodItemsSelectors.add(false);
    String foodItemName = item.name;
    int foodItemCallories = item.callories;
    Row foodItem = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Text(
              '${foodItemName}'
            ),
            Text(
              '${foodItemCallories} ккал'
            )
          ]
        ),
        Row(
          children: [
            VerticalDivider(
                thickness: 1
            ),
            Checkbox(
              value: foodItemsSelectors[foodItemIndex],
              onChanged: (value) {
                setState(() {
                  foodItemsSelectors[foodItemIndex] = value!;
                  bool isFoodItemSelected = foodItemsSelectors.any((element) => element);
                  if (isFoodItemSelected) {
                    nextBtnTitle = foodHistoryBtnTitle;
                  } else {
                    nextBtnTitle = initialBtnTitle;
                  }
                });
              }
            )
          ]
        )
      ]
    );
    foodItems.add(foodItem);
  }

    goNext(context) {
      bool isFoodItemSelected = foodItemsSelectors.any((element) => element);
      if (isFoodItemSelected) {
        Navigator.pushNamed(
          context,
          '/food/history',
          arguments: {
            'foodType': foodType
          });
      } else {
        Navigator.pushNamed(
          context,
          '/food',
          arguments: {
            'isAddFoodRecord': false
          }
        );
      }
    }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        nextBtnTitle = initialBtnTitle;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      if (arguments != null) {
        print(arguments['foodType']);
        foodType = arguments['foodType'];
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(
              foodType
          ),

          actions: [
            FlatButton(
              child: Text(
                nextBtnTitle,
                style: TextStyle(
                  fontSize: 20
                )
              ),
              onPressed: () {
                goNext(context);
              }
            )
          ]
        ),
        backgroundColor: Color.fromARGB(255, 225, 225, 225),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              padding: EdgeInsets.all(
                15
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/food/add');
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add
                        ),
                        Text(
                          'Добав. нов. прием пищи',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        )
                      ]
                    )
                  ),
                  FutureBuilder(
                    future: this.handler.retrieveFoodItems(),
                    builder: (BuildContext context, AsyncSnapshot<List<FoodItem>> snapshot) {
                      int snapshotsCount = 0;
                      if (snapshot.data != null) {
                        snapshotsCount = snapshot.data!.length;
                        foodItems = [];
                        for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
                          addFoodItem(snapshot.data!.elementAt(snapshotIndex));
                        }
                      }
                      if (snapshot.hasData) {
                        return Column(
                            children: [
                              Container(
                                  height: 250,
                                  child: SingleChildScrollView(
                                      child: Column(
                                          children: foodItems
                                      )
                                  )
                              )
                            ]
                        );
                      } else {
                        return Column(

                        );
                      }
                      return Column(

                      );
                    }
                  )
                ]
              )
            )
          ]
        )
    );
  }

}

class AddFoodItemActivity extends StatefulWidget {

  const AddFoodItemActivity({Key? key}) : super(key: key);

  @override
  State<AddFoodItemActivity> createState() => _AddFoodItemActivityState();

}

class _AddFoodItemActivityState extends State<AddFoodItemActivity> {

  late DatabaseHandler handler;
  String foodItemName = '';
  int foodItemkKals = 0;

  addFoodItem(BuildContext context) {
    handler.addNewFoodItem(foodItemName, foodItemkKals, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '');
    Navigator.pushNamed(context, '/food/record');
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return (
      Scaffold(
        appBar: AppBar(
          title: Text(
            'Добав. нов. прием пищи'
          )
        ),
        backgroundColor: Color.fromARGB(255, 225, 225, 225),
        body: Column(
          children: [
            Container(
              child: TextField(
                decoration: new InputDecoration.collapsed(
                  hintText: 'Название продукта',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.0
                    )
                  )
                ),
                // controller: TextEditingController()..text = '${newCustomTimerHours}:${newCustomTimerMinutes}:${newCustomTimerSeconds}',
                onChanged: (value) {
                  setState(() {
                    foodItemName = value;
                  });
                }
              )
            ),
            Row(
              children: [
                Text(
                    'Калорий на порцию'
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        left: 150
                      ),
                      width: 75,
                      child: TextField(
                        decoration: new InputDecoration.collapsed(
                          hintText: '',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1.0
                            )
                          )
                        ),
                        // controller: TextEditingController()..text = '${newCustomTimerHours}:${newCustomTimerMinutes}:${newCustomTimerSeconds}',
                        onChanged: (value) {
                          setState(() {
                            foodItemkKals = int.parse(value);
                          });
                        }
                      )
                    ),
                    Text(
                      'ккал'
                    )
                  ]
                )
              ]
            ),
            Container(
              margin: EdgeInsets.symmetric(
                vertical: 25
              ),
              child: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 175, 175, 175)
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      side: BorderSide(
                        color: Color.fromARGB(255, 150, 150, 150)
                      )
                    )
                  )
                ),
                onPressed: () {

                },
                child: Text(
                  'Добав. питат. вещества',
                  textAlign: TextAlign.center
                )
              )
            )
          ]
        ),
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Text(
                  'Отмена'
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  )
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/food/record');
                }
              ),
              TextButton(
                child: Text(
                  'Сохранить'
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 0, 0, 0)
                  )
                ),
                onPressed: () {
                  addFoodItem(context);
                }
              )
            ]
          )
        ],
      )
    );
  }

}

class FoodHistoryActivity extends StatefulWidget {

  const FoodHistoryActivity({Key? key}) : super(key: key);

  @override
  State<FoodHistoryActivity> createState() => _FoodHistoryActivityState();

}

class _FoodHistoryActivityState extends State<FoodHistoryActivity> {

  late DatabaseHandler handler;
  String foodType = '';
  var contextMenuBtns = {
    'Завтрак',
    'Обед',
    'Ужин',
    'Утренний перекус',
    'Дневной перекус',
    'Вечерний перекус'
  };

  addFoodRecord(context) {
    handler.addNewFoodRecord(foodType);
    Navigator.pushNamed(context, '/food');
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      if (arguments != null) {
        print(arguments['foodType']);
        foodType = arguments['foodType'];
      }
    });

    return (
        Scaffold(
            appBar: AppBar(
              title: Text(
                'Журнал питания'
              ),
              actions: [
                FlatButton(
                  child: Text(
                    'Готово',
                    style: TextStyle(
                      fontSize: 20
                    )
                  ),
                  onPressed: () {
                    addFoodRecord(context);
                  }
                )
              ]
            ),
            backgroundColor: Color.fromARGB(255, 225, 225, 225),
            body: Column(
                children: [
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return contextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            foodType,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24
                            )
                        ),
                        Icon(
                            Icons.arrow_drop_down
                        )
                      ]
                    ),
                    onSelected: (String selectedMenuItemIndex) {
                      print('selectedMenuItemIndex: $selectedMenuItemIndex');
                      setState(() {
                        foodType = '${selectedMenuItemIndex}';
                      });
                    },
                  ),
                  TextButton(
                    child: Text(
                      '17:48',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 0, 0, 0)
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          175.0,
                          45.0
                        )
                      )
                    )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: 15
                    ),
                    padding: EdgeInsets.all(
                      15
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Всего каллорий: 50 ккал',
                              style: TextStyle(
                                fontSize: 20
                              )
                            ),
                            Text(
                              'Углеводы 0 г, Жиры 0 г, Протеин 0 г',
                              style: TextStyle(
                                color: Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          ]
                        ),
                        Icon(
                          Icons.linked_camera_sharp
                        )
                      ]
                    )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 15
                    ),
                    padding: EdgeInsets.all(
                      15
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255)
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Row(
                            children: [
                              Icon(
                                Icons.add
                              ),
                              Text(
                                'Добавить продукты',
                                style: TextStyle(
                                  fontSize: 20
                                )
                              )
                            ]
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/food/record');
                          }
                        )
                      ]
                    )
                  ),
                  TextButton(
                    child: Text(
                      'Сохр. как польз. блюдо',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )
                    ),
                    onPressed: () {

                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 200, 200, 200)
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 0, 0, 0)
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0)
                        )
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(
                          275.0,
                          45.0
                        )
                      )
                    )
                  )
                ]
            )
        )
    );
  }

}

class ExercisesListActivity extends StatefulWidget {

  const ExercisesListActivity({Key? key}) : super(key: key);

  @override
  State<ExercisesListActivity> createState() => _ExercisesListActivityState();

}

class _ExercisesListActivityState extends State<ExercisesListActivity> {

  late DatabaseHandler handler;
  var contextMenuBtns = {
    'Скрыть упражнения',
    'Сброс по умолчанию',
    'Аксессуары'
  };
  List<Widget> exercises = [];
  List<bool> exercisesSelectors = [];
  bool isSelectionMode = false;

  void addExercise(BodyRecord record) {
    int exerciseIndex = exercises.length;
    String exerciseName = 'Ходьба';
    // exerciseName = record.name;
    bool isFavoriteExercise = false;
    // bool isFavoritedExercise = record.is_activated;
    exercisesSelectors.add(false);
    GestureDetector exercise = GestureDetector(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    isSelectionMode ?
                      Checkbox(
                        value: exercisesSelectors[exerciseIndex],
                        onChanged: (value) {
                          setState(() {
                            exercisesSelectors[exerciseIndex] = !exercisesSelectors[exerciseIndex];
                          });
                        }
                      )
                    :
                      Column()
                  ]
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: 15
                          ),
                          child: Icon(
                              Icons.directions_walk,
                              color: Color.fromARGB(255, 0, 200, 0)
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 10
                          ),
                          child: Text(
                            exerciseName,
                            style: TextStyle(
                                fontSize: 20
                            )
                          )
                        )
                      ]
                    ),
                    Divider(
                      height: 1.0,
                      thickness: 1.0,
                      color: Color.fromARGB(255, 0, 0, 0)
                    )
                  ]
                )
              ]
            ),
            Column(
              children: [
                isFavoriteExercise ?
                  Icon(
                    Icons.star_rounded,
                    color: Color.fromARGB(255, 255, 225, 0)
                  )
                :
                  Icon(
                    Icons.star_outline_rounded,
                    color: Color.fromARGB(255, 150, 150, 150)
                  )
              ]
            )
          ]
        ),
        height: 65
      ),
      onLongPress: () {
        setState(() {
          isSelectionMode = true;
        });
      }
    );
    exercises.add(exercise);
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Упражнения'
        ),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) {
              return contextMenuBtns.map((String choice) {
                return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice)
                );
              }).toList();
            },
          )
        ]
      ),
      body: FutureBuilder(
        future: this.handler.retrieveBodyRecords(),
        builder: (BuildContext context, AsyncSnapshot<List<BodyRecord>> snapshot) {
          int snapshotsCount = 0;
          if (snapshot.data != null) {
            snapshotsCount = snapshot.data!.length;
            exercises = [];
            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
              addExercise(snapshot.data!.elementAt(snapshotIndex));
            }
          }
          if (snapshot.hasData) {
            return WillPopScope(
              onWillPop: () async {
                if (isSelectionMode) {
                  setState(() {
                    isSelectionMode = false;
                    exercisesSelectors.fillRange(0, exercisesSelectors.length - 1, false);
                  });
                  return false;
                }
                return true;
              },
              child: Column(
                children: [
                  Container(
                    height: 250,
                    child: SingleChildScrollView(
                      child: Column(
                          children: exercises
                      )
                    )
                  )
                ]
              )
            );
          } else {
            return Column(

            );
          }
          return Column(

          );
        }
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 0, 0, 0)
                )
              ),
              child: Row(
                children: [
                  Text(
                    'Добавить тренировки'
                  ),
                  Icon(
                    Icons.chevron_right
                  )
                ]
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/exercise/add');
              }
            )
          ]
        )
      ],
    );
  }

}

class AddExerciseActivity extends StatefulWidget {

  const AddExerciseActivity({Key? key}) : super(key: key);

  @override
  State<AddExerciseActivity> createState() => _AddExerciseActivityState();

}

class _AddExerciseActivityState extends State<AddExerciseActivity> {

  late DatabaseHandler handler;
  List<Widget> exercises = [];
  List<bool> exercisesSelectors = [];

  void addExercise(BodyRecord record) {
    int exerciseIndex = exercises.length;
    String exerciseName = 'Ходьба';
    // exerciseName = record.name;
    exercisesSelectors.add(false);
    Row exercise = Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: exercisesSelectors[exerciseIndex],
          onChanged: (value) {
            setState(() {
              exercisesSelectors[exerciseIndex] = !exercisesSelectors[exerciseIndex];
            });
          }
        ),
        Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: 15
                  ),
                  child: Icon(
                    Icons.directions_walk,
                    color: Color.fromARGB(255, 0, 200, 0)
                  )
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: 10
                  ),
                  child: Text(
                    exerciseName,
                    style: TextStyle(
                      fontSize: 20
                    )
                  )
                )
              ]
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: Color.fromARGB(255, 0, 0, 0)
            )
          ]
        )
      ]
    );
    exercises.add(exercise);
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exercisesSelectors.any((element) => element) ?
            'Выбрано: ${exercisesSelectors.where((element) => element).length}'
          :
            'Добавить тренировки'
        ),
        actions: [
          FlatButton(
            textColor: Color.fromARGB(255, 255, 255, 255),
            child: Icon(
              Icons.search
            ),
            onPressed: () {

            }
          )
        ]
      ),
      body: FutureBuilder(
        future: this.handler.retrieveBodyRecords(),
        builder: (BuildContext context, AsyncSnapshot<List<BodyRecord>> snapshot) {
          int snapshotsCount = 0;
          if (snapshot.data != null) {
            snapshotsCount = snapshot.data!.length;
            exercises = [];
            for (int snapshotIndex = 0; snapshotIndex <
                snapshotsCount; snapshotIndex++) {
              addExercise(snapshot.data!.elementAt(snapshotIndex));
            }
          }
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  height: 250,
                  child: SingleChildScrollView(
                    child: Column(
                        children: exercises
                    )
                  )
                )
              ]
            );
          } else {
            return Column(

            );
          }
          return Column(

          );
        }
      ),
      persistentFooterButtons: [
        Column(
          children: [
            exercisesSelectors.any((element) => element) ?
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Column(
                      children: [
                        Icon(
                          Icons.add
                        ),
                        Text(
                          'Добавить'
                        )
                      ]
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/exercise/list');
                    }
                  )
                ]
              )
            :
              Row(
                children: []
              )
          ]
        )
      ]
    );
  }

}