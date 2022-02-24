import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:sqlite_viewer/sqlite_viewer.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:pedometer/pedometer.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
/*
не работает account-manager-plugin
import 'package:account_manager_plugin/account_manager_plugin.dart';
*/
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      home: const MyHomePage(),
      routes: {
        '/main': (context) => const MyHomePage(),
        '/active': (context) => const ActiveActivity(),
        '/walk': (context) => const WalkActivity(),
        '/exercise/results': (context) => const RecordExerciseResultsActivity(),
        '/exercise/started': (context) => const RecordStartedExerciseActivity(),
        '/exercise/record': (context) => const RecordExerciseActivity(),
        '/exercise/add': (context) => const AddExerciseActivity(),
        '/exercise/list': (context) => const ExercisesListActivity(),
        '/exercise': (context) => const ExerciseActivity(),
        '/food/record': (context) => const RecordFoodActivity(),
        '/food/add': (context) => const AddFoodItemActivity(),
        '/food/history': (context) => const FoodHistoryActivity(),
        '/food': (context) => const FoodActivity(),
        '/sleep/record': (context) => const RecordSleepActivity(),
        '/sleep': (context) => const SleepActivity(),
        '/body/record': (context) => const RecordBodyActivity(),
        '/body': (context) => const BodyActivity(),
        '/water': (context) => const WaterActivity(),
        '/account/edit': (context) => const EditMyPageActivity(),
        '/settings/general/measure': (context) => const SettingsGeneralMeasureActivity(),
        '/settings/privacy/phone': (context) => const SettingsPrivacyPhoneActivity(),
        '/settings': (context) => const SettingsActivity(),
        '/foryou': (context) => const ForYouActivity(),
        '/events': (context) => const EventsActivity(),
        '/notifications': (context) => const NotificationsActivity()
      }
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key}) : super(key: key);

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
  List<bool> controllersActives = [
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];
  String title = '';
  String appName = 'Softtrack здоровье';
  String elementsControlHeader = 'Управление элементами';
  bool isSelectionMode = false;
  List<bool> initialControllersActives = [
    true,
    true,
    true,
    true,
    true,
    true,
    true
  ];

  /*
  sdk не позволяет использовать педометр
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  */
  String _steps = '0';
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool isExerciseEnabled = false;
  String exerciseType = '';
  String exerciseDuration = '00:00';
  late Timer startedTimer;
  int startedTimerSeconds = 0;
  int countSecondsInMinute = 60;
  int countMinutesInHour = 60;
  int initialSeconds = 0;
  int startedTimerMinutes = 0;
  int initialMinutes = 0;
  int startedTimerHours = 0;
  String oneCharPrefix = '0';
  final String stopWatchTitleSeparator = ':';
  String exerciseStartTime = '00:00';

  void addGlass() {
    setState(() {
      removeGlassesBtnColor = enabledGlassesBtnColor;
      glassesCount++;
      handler.updateWaterIndicators(glassesCount);
    });
  }

  void removeGlass() {
    bool isGlassesCountEmpty = glassesCount <= 0;
    bool isGlassesCountNotEmpty = !isGlassesCountEmpty;
    if (isGlassesCountNotEmpty) {
      setState(() {
        glassesCount--;
        handler.updateWaterIndicators(glassesCount);
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

  void onSelectNotification(String? notification) async {
    print('${notification}');
  }
  
  void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    print('notification info: ${id}, ${title}, ${body}, ${payload}');
    /*showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              Navigator.of(context, rootNavigator: true).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SecondScreen(payload),
                ),
              );
            },
          )
        ],
      ),
    );*/
  }

  initializeNotifications() async {
    // setState(() async {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
      // AndroidInitializationSettings('launch_background');
      AndroidInitializationSettings('steps_logo');
      final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      );
      final MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
      final InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
          macOS: initializationSettingsMacOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
      await showStepsNotification();
    // });
  }

  showStepsNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('0', 'softtrack-health-notifications-channel',
        channelDescription: 'softtrack-health-notifications-channel-desc',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker'
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, '0 шагов', 'Нет данных о шагах за сегодня.', platformChannelSpecifics,
        payload: 'item x'
    );
  }

  updateController(controllerName, controllerIndex) {
    handler.retrieveControllers().then((value) {
      for (Controller controller in value) {
        if (controllerName == controller.name) {
          print('controller.is_activated: ${controller.is_activated}');
          // handler.updateIsActivatedController(controllerName, controller.is_activated == 1 ? 0 : 1);
          break;
        }
      }
      setState(() {
        controllersActives[controllerIndex] = !controllersActives[controllerIndex];
      });
    });
  }

  saveElementsControl() {
    setState(() {
      title = appName;
      isSelectionMode = false;
    });
    handler.updateIsActivatedController('active', controllersActives[0] ? 1 : 0);
    handler.updateIsActivatedController('walk', controllersActives[1] ? 1 : 0);
    handler.updateIsActivatedController('exercise', controllersActives[2] ? 1 : 0);
    handler.updateIsActivatedController('food', controllersActives[3] ? 1 : 0);
    handler.updateIsActivatedController('sleep', controllersActives[4] ? 1 : 0);
    handler.updateIsActivatedController('body', controllersActives[5] ? 1 : 0);
    handler.updateIsActivatedController('water', controllersActives[6] ? 1 : 0);
    initialControllersActives[0] = controllersActives[0];
    initialControllersActives[1] = controllersActives[1];
    initialControllersActives[2] = controllersActives[2];
    initialControllersActives[3] = controllersActives[3];
    initialControllersActives[4] = controllersActives[4];
    initialControllersActives[5] = controllersActives[5];
    initialControllersActives[6] = controllersActives[6];
  }

  cancelElementsControl() {
    setState(() {
      title = appName;
      isSelectionMode = false;
      controllersActives[0] = initialControllersActives[0];
      controllersActives[1] = initialControllersActives[1];
      controllersActives[2] = initialControllersActives[2];
      controllersActives[3] = initialControllersActives[3];
      controllersActives[4] = initialControllersActives[4];
      controllersActives[5] = initialControllersActives[5];
      controllersActives[6] = initialControllersActives[6];
    });
  }

  // getAccount() async {
  //   List<dynamic> accounts = await AccountManagerPlugin.getAccounts;
  //   print('${accounts.length}');
  // }

  void runStartedTimer() async {
    setState(() {
      startedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        startedTimerSeconds++;
        bool isToggleSecond = startedTimerSeconds == countSecondsInMinute;
        if (isToggleSecond) {
          startedTimerSeconds = initialSeconds;
          startedTimerMinutes++;
          bool isToggleMinute = startedTimerMinutes == countMinutesInHour;
          if (isToggleMinute) {
            startedTimerMinutes = initialMinutes;
            startedTimerHours++;
          }
        }
        String updatedHoursText = '${startedTimerHours}';
        int countHoursChars = updatedHoursText.length;
        bool isAddHoursPrefix = countHoursChars == 1;
        if (isAddHoursPrefix) {
          updatedHoursText = oneCharPrefix + updatedHoursText;
        }
        String updatedMinutesText = '${startedTimerMinutes}';
        int countMinutesChars = updatedMinutesText.length;
        bool isAddMinutesPrefix = countMinutesChars == 1;
        if (isAddMinutesPrefix) {
          updatedMinutesText = oneCharPrefix + updatedMinutesText;
        }
        String updatedSecondsText = '${startedTimerSeconds}';
        int countSecondsChars = updatedSecondsText.length;
        bool isAddSecondsPrefix = countSecondsChars == 1;
        if (isAddSecondsPrefix) {
          updatedSecondsText = oneCharPrefix + updatedSecondsText;
        }
        String currentTime = updatedHoursText + ":" + updatedMinutesText + ":" + updatedSecondsText;
        setState(() {
          exerciseDuration = currentTime;
        });
        handler.updateExerciseIndicators(1, '00:00', exerciseType, currentTime, false);
        print('debug: $currentTime');

      });
    });
  }

  @override
  initState() {
    super.initState();
    removeGlassesBtnColor = enabledGlassesBtnColor;
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        this.handler.retrieveIndicators().then((indicators) {
          if (indicators.length >= 1) {
            Indicators indicatorsItem = indicators[0];
            glassesCount = indicatorsItem.water;
            int rawIsExerciseEnabled = indicatorsItem.is_exercise_enabled;
            setState(() {
              isExerciseEnabled = rawIsExerciseEnabled == 1;
              exerciseType = indicatorsItem.exercise_type;
              exerciseDuration = indicatorsItem.exercise_duration;
              exerciseStartTime = indicatorsItem.exercise_start_time;
              if (isExerciseEnabled) {
                List<String> exerciseDurationParts = exerciseDuration.split(stopWatchTitleSeparator);
                startedTimerHours = int.parse(exerciseDurationParts[0]);
                startedTimerMinutes = int.parse(exerciseDurationParts[1]);
                startedTimerSeconds = int.parse(exerciseDurationParts[2]);
                runStartedTimer();
              }
            });
          }
          print('glassesCount: ${glassesCount}, isExerciseEnabled: ${isExerciseEnabled}');
          this.handler.retrieveControllers().then((controllers) {
            print('controllers: ${controllers.length}');
            for (Controller controller in controllers) {
              controllersActives[controller.id! - 1] = controller.is_activated == 1 ? true : false;
              initialControllersActives[controller.id! - 1] = controller.is_activated == 1 ? true : false;
            }
          });
        });
      });
    });
    /*
    sdk не позволяет использовать pedometer
    initPlatformState();
    */
    /*
      не работает account-manager-plugin
      getAccount();
    */

    initializeNotifications();
    // showStepsNotification();

    setState(() {
      title = appName;
    });

  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
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
              onSelected: (menuItemName) {
                if (currentTab == 0) {
                  if (menuItemName == 'Управление элементами') {
                    setState(() {
                      title = elementsControlHeader;
                      isSelectionMode = true;
                    });
                  }
                } else if (currentTab == 2) {
                  if (menuItemName == 'Направления фитнеса') {

                  } else if (menuItemName == 'Журнал программы') {

                  }
                }
                if (menuItemName == 'Настр.') {
                  Navigator.pushNamed(context, '/settings');
                } else if (menuItemName == 'События') {
                  Navigator.pushNamed(context, '/events');
                } else if (menuItemName == 'Уведомления') {
                  Navigator.pushNamed(context, '/notifications');
                } else if (menuItemName == 'Для вас') {
                  Navigator.pushNamed(context, '/foryou');
                }
              }
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
        persistentFooterButtons: [
          isSelectionMode ?
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 0, 0, 0)
                    )
                  ),
                  child: Text(
                    'Отмена'
                  ),
                  onPressed: () {
                    cancelElementsControl();
                  }
                ),
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(255, 0, 0, 0)
                    )
                  ),
                  child: Text(
                    'Сохранить'
                  ),
                  onPressed: () {
                    saveElementsControl();
                  }
                )
              ]
            )
          :
            Row(

            )
        ],
        body: TabBarView(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 225, 225, 225)
                  ),
                  child: Column(
                    children: [
                      isSelectionMode || (!isSelectionMode && controllersActives[0]) ?
                        GestureDetector(
                          onTap: () {
                            // Navigator.pushNamed(context, '/active');
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
                                    isSelectionMode ?
                                      GestureDetector(
                                        child: (
                                          controllersActives[0] ?
                                            Icon(
                                              Icons.remove_circle,
                                              color: Color.fromARGB(255, 255, 0, 0),
                                            )
                                          :
                                          Icon(
                                            Icons.add_circle,
                                            color: Color.fromARGB(255, 0, 200, 0),
                                          )
                                        ),
                                        onTap: () {
                                          updateController('active', 0);
                                        }
                                      )
                                    :
                                      Row()
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
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[1]) ?
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
                                      isSelectionMode ?
                                        GestureDetector(
                                          child: (
                                            controllersActives[1] ?
                                            Icon(
                                              Icons.remove_circle,
                                              color: Color.fromARGB(255, 255, 0, 0),
                                            )
                                                :
                                            Icon(
                                              Icons.add_circle,
                                              color: Color.fromARGB(255, 0, 200, 0),
                                            )
                                          ),
                                          onTap: () {
                                            updateController('walk', 1);
                                          }
                                        )
                                      :
                                        Row()
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
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[2]) ?
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/exercise');
                          },
                          child: (
                            isExerciseEnabled ?
                              GestureDetector(
                                child: Container(
                                  padding: EdgeInsets.all(
                                    15
                                  ),
                                  margin: EdgeInsets.symmetric(
                                    vertical: 15
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 0, 150, 0)
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            exerciseType,
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 200, 200, 200)
                                            )
                                          ),
                                          Text(
                                            'Начало: ${exerciseStartTime}',
                                            style: TextStyle(
                                              color: Color.fromARGB(255, 200, 200, 200)
                                            )
                                          )
                                        ]
                                      ),
                                      Text(
                                        exerciseDuration,
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 200, 200, 200)
                                        )
                                      )
                                    ]
                                  )
                                ),
                                onTap: () {
                                  if (startedTimer != null) {
                                    startedTimer.cancel();
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    '/exercise/started',
                                    arguments: {
                                      'exerciseType': exerciseType
                                    }
                                  );
                                }
                              )
                            :
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        isSelectionMode ?
                                          GestureDetector(
                                            child: (
                                              controllersActives[2] ?
                                              Icon(
                                                Icons.remove_circle,
                                                color: Color.fromARGB(255, 255, 0, 0),
                                              )
                                                  :
                                              Icon(
                                                Icons.add_circle,
                                                color: Color.fromARGB(255, 0, 200, 0),
                                              )
                                            ),
                                            onTap: () {
                                              updateController('exercise', 2);
                                            }
                                          )
                                        :
                                          Row()
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
                                            // handler.addNewExerciseRecord('Ходьба', '22.11.2000', '00:00:00');
                                            Navigator.pushNamed(
                                              context,
                                              '/exercise/record',
                                              arguments: {
                                                'exerciseType': 'Ходьба'
                                              }
                                            );
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
                                            // handler.addNewExerciseRecord('Бег', '22.11.2000', '00:00:00');
                                            Navigator.pushNamed(
                                              context,
                                              '/exercise/record',
                                              arguments: {
                                                'exerciseType': 'Бег'
                                              }
                                            );
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
                                              // handler.addNewExerciseRecord('Велоспорт', '22.11.2000', '00:00:00');
                                              Navigator.pushNamed(
                                                context,
                                                '/exercise/record',
                                                arguments: {
                                                  'exerciseType': 'Велоспорт'
                                                }
                                              );
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
                            )
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[3]) ?
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
                                    isSelectionMode ?
                                      GestureDetector(
                                        child: (
                                          controllersActives[3] ?
                                          Icon(
                                            Icons.remove_circle,
                                            color: Color.fromARGB(255, 255, 0, 0),
                                          )
                                              :
                                          Icon(
                                            Icons.add_circle,
                                            color: Color.fromARGB(255, 0, 200, 0),
                                          )
                                        ),
                                        onTap: () {
                                          updateController('food', 3);
                                        }
                                      )
                                    :
                                      Row()
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
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[4]) ?
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
                                      isSelectionMode ?
                                        GestureDetector(
                                          child: (
                                            controllersActives[4] ?
                                            Icon(
                                              Icons.remove_circle,
                                              color: Color.fromARGB(255, 255, 0, 0),
                                            )
                                                :
                                            Icon(
                                              Icons.add_circle,
                                              color: Color.fromARGB(255, 0, 200, 0),
                                            )
                                          ),
                                          onTap: () {
                                            updateController('sleep', 4);
                                          }
                                        )
                                      :
                                        Row()
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
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[5]) ?
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
                                    isSelectionMode ?
                                      GestureDetector(
                                        child: (
                                          controllersActives[5] ?
                                          Icon(
                                            Icons.remove_circle,
                                            color: Color.fromARGB(255, 255, 0, 0),
                                          )
                                              :
                                          Icon(
                                            Icons.add_circle,
                                            color: Color.fromARGB(255, 0, 200, 0),
                                          )
                                        ),
                                        onTap: () {
                                          updateController('body', 5);
                                        }
                                      )
                                    :
                                      Row()
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
                        )
                      :
                        Row(),
                      isSelectionMode || (!isSelectionMode && controllersActives[6]) ?
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
                                  isSelectionMode ? 
                                    GestureDetector(
                                      child: (
                                          controllersActives[6] ?
                                          Icon(
                                            Icons.remove_circle,
                                            color: Color.fromARGB(255, 255, 0, 0),
                                          )
                                              :
                                          Icon(
                                            Icons.add_circle,
                                            color: Color.fromARGB(255, 0, 200, 0),
                                          )
                                      ),
                                      onTap: () {
                                        updateController('water', 6);
                                      }
                                    )
                                  :
                                    Row()
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
                    :
                      Row()
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
                              // Image.network(
                              //   'https://cdn3.iconfinder.com/data/icons/generic-avatars/128/avatar_portrait_man_male-256.png',
                              //   width: 100,
                              //   height: 100
                              // ),
                          // Image.network(
                          //                                 'https://cdn3.iconfinder.com/data/icons/generic-avatars/128/avatar_portrait_man_male-256.png',
                          //                                 width: 100,
                          //                                 height: 100
                          //                               )
                              Image.asset(
                                'assets/images/user_logo.png',
                                width: 100,
                                height: 100
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/add_alarm');
                                },
                                child: TextButton(
                                  child: Text(
                                    'Изменить'
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/account/edit');
                                  }
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

  late DatabaseHandler handler;
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
        handler.updateWaterIndicators(glassesCount);
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
      handler.updateWaterIndicators(glassesCount);
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
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
      });
      this.handler.retrieveIndicators().then((indicators) {
        if (indicators.length >= 1) {
          Indicators indicatorsItem = indicators[0];
          glassesCount = indicatorsItem.water;
        }
        print('glassesCount: ${glassesCount}');
      });
    });
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
                  // handler.addNewBodyRecord('', 0, 0, 0.0, '');
                  Navigator.pushNamed(context, '/body/record');
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
                      // Navigator.pushNamed(context, '/food/add');
                      Navigator.pushNamed(
                          context,
                          '/food/add',
                          arguments: {
                            'foodType': foodType
                          }
                      );
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
  String foodType = '';
  bool isAddNutrients = false;
  int foodItemTotalCarbs = 0;
  int foodItemTotalFats = 0;
  int foodItemProtein = 0;
  int foodItemSaturatedFats = 0;
  int foodItemTransFats = 0;
  int foodItemCholesterol = 0;
  int foodItemSodium = 0;
  int foodItemPotassium = 0;
  int foodItemCellulose = 0;
  int foodItemSugar = 0;
  int foodItemA = 0;
  int foodItemC = 0;
  int foodItemCalcium = 0;
  int foodItemIron = 0;
  double foodItemPortions = 0.0;
  String foodItemType = '';

  addFoodItem(BuildContext context) {
    handler.addNewFoodItem(foodItemName, foodItemkKals, foodItemTotalCarbs, foodItemTotalFats, foodItemProtein, foodItemSaturatedFats, foodItemTransFats, foodItemCholesterol, foodItemSodium, foodItemPotassium, foodItemCellulose, foodItemSugar, foodItemA, foodItemC, foodItemCalcium, foodItemIron, foodItemPortions, foodType);
    // Navigator.pushNamed(context, '/food/record');
    Navigator.pushNamed(
        context,
        '/food/record',
        arguments: {
          'foodType': foodType
        }
    );
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
              child: (
                isAddNutrients ?
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Всего углеводов'
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
                                      foodItemTotalCarbs = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Всего жиров'
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
                                      foodItemTotalFats = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Протеин'
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
                                      foodItemProtein = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Насыщенные жиры'
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
                                      foodItemSaturatedFats = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Трансжиры'
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
                                        foodItemTransFats = int.parse(value);
                                      });
                                    }
                                  )
                                ),
                                Text(
                                  'г'
                                )
                              ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Холестерин'
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
                                      foodItemCholesterol = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'мг'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Натрий'
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
                                      foodItemSodium = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'мг'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Калий'
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
                                      foodItemPotassium = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'мг'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Клетчатка'
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
                                      foodItemCellulose = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Сахар'
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
                                      foodItemSugar = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                'г'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Витамин A(100% = 900 мкг RAE)*'
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: 100
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
                                      foodItemA = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                '%'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Витамин C (100% = 90мг)*'
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
                                      foodItemC = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                '%'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Кальций (100% = 1300мг)*'
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
                                      foodItemCalcium = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                '%'
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        children: [
                          Text(
                            'Железо (100% = 18мг)*'
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
                                      foodItemIron = int.parse(value);
                                    });
                                  }
                                )
                              ),
                              Text(
                                '%'
                              )
                            ]
                          )
                        ]
                      )
                    ]
                  )
                :
                  TextButton(
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
                      setState(() {
                        isAddNutrients = true;
                      });
                    },
                    child: Text(
                      'Добав. питат. вещества',
                      textAlign: TextAlign.center
                    )
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
                  // Navigator.pushNamed(context, '/food/record');
                  Navigator.pushNamed(
                      context,
                      '/food/record',
                      arguments: {
                        'foodType': foodType
                      }
                  );
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
  List<int> exercisesIds = [];
  List<bool> exercisesFavorites = [];

  void addExercise(Exercise record) {
    int exerciseId = record.id!;
    int exerciseIndex = exercises.length;
    String exerciseName = 'Ходьба';
    exerciseName = record.name;
    bool isFavoriteExercise = false;
    int rawIsFavoritedExercise = record.is_favorite;
    isFavoriteExercise = rawIsFavoritedExercise == 1;
    bool isActivatedExercise = false;
    int rawIsActivatedExercise = record.is_activated;
    isActivatedExercise = rawIsActivatedExercise == 1;
    if (isActivatedExercise) {
      exercisesIds.add(exerciseId);
      exercisesSelectors.add(false);
      exercisesFavorites.add(isFavoriteExercise);
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
                  GestureDetector(
                    child: exercisesFavorites[exerciseIndex] ?
                        Icon(
                          Icons.star_rounded,
                          color: Color.fromARGB(255, 255, 225, 0)
                        )
                      :
                        Icon(
                          Icons.star_outline_rounded,
                          color: Color.fromARGB(255, 150, 150, 150)
                        )
                    ,
                    onTap: () {
                      setState(() {
                        exercisesFavorites[exerciseIndex] = !exercisesFavorites[exerciseIndex];
                      });
                      handler.updateIsFavorite(exercisesIds[exerciseIndex], exercisesFavorites[exerciseIndex]);
                    }
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
        future: this.handler.retrieveExercises(),
        builder: (BuildContext context, AsyncSnapshot<List<Exercise>> snapshot) {
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
          mainAxisAlignment: (
            isSelectionMode ?
              MainAxisAlignment.center
            :
              MainAxisAlignment.end
          ),
          children: [
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 0, 0, 0)
                )
              ),
              child: (
                isSelectionMode ?
                  Column(
                    children: [
                      Icon(
                        Icons.remove_circle
                      ),
                      Text(
                        'Cкрыть'
                      )
                    ]
                  )
                :
                  Row(
                    children: [
                      Text(
                        'Добавить тренировки'
                      ),
                      Icon(
                        Icons.chevron_right
                      )
                    ]
                  )
              ),
              onPressed: () {
                if (isSelectionMode) {
                  int exercisesIndex = -1;
                  for (int exerciseId in exercisesIds) {
                    exercisesIndex++;
                    if (exercisesSelectors[exercisesIndex]) {
                      handler.updateIsActivated(exerciseId, 0);
                    }
                  }
                  setState(() {
                    isSelectionMode = false;
                  });
                } else {
                  Navigator.pushNamed(context, '/exercise/add');
                }
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
  List<int> exercisesIds = [];

  void addExercise(Exercise record) {
    int exerciseId = record.id!;
    int exerciseIndex = exercises.length;
    String exerciseName = 'Ходьба';
    exerciseName = record.name;
    int rawIsExerciseActivated = record.is_activated;
    bool isExerciseActivated = rawIsExerciseActivated == 1;
    bool isExerciseNotActivated = !isExerciseActivated;
    if (isExerciseNotActivated) {
      exercisesIds.add(exerciseId);
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
        future: this.handler.retrieveExercises(),
        builder: (BuildContext context, AsyncSnapshot<List<Exercise>> snapshot) {
          int snapshotsCount = 0;
          if (snapshot.data != null) {
            snapshotsCount = snapshot.data!.length;
            exercises = [];
            for (int snapshotIndex = 0; snapshotIndex < snapshotsCount; snapshotIndex++) {
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
                      int exercisesIndex = -1;
                      for (int exerciseId in exercisesIds) {
                        exercisesIndex++;
                        if (exercisesSelectors[exercisesIndex]) {
                          handler.updateIsActivated(exerciseId, 1);
                        }
                      }
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

class RecordExerciseActivity extends StatefulWidget {

  const RecordExerciseActivity({Key? key}) : super(key: key);

  @override
  State<RecordExerciseActivity> createState() => _RecordExerciseActivityState();

}

class _RecordExerciseActivityState extends State<RecordExerciseActivity> {

  late DatabaseHandler handler;
  String exerciseType = 'Ходьба';
  var contextMenuBtns = {
    ''
  };

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
        print(arguments['exerciseType']);
        exerciseType = arguments['exerciseType'];
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exerciseType
        ),
        actions: [
          FlatButton(
            child: Icon(
              Icons.music_note
            ),
            onPressed: () {

            },
            textColor: Color.fromARGB(255, 255, 255, 255)
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
      body: FlutterMap(
        options: MapOptions(
          center: latLng.LatLng(51.5, -0.09),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
            attributionBuilder: (_) {
              return Text("© OpenStreetMap contributors");
            },
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: latLng.LatLng(51.5, -0.09),
                builder: (ctx) =>
                  Container(
                    child: Icon(
                      Icons.near_me
                    ),
                  ),
              ),
            ],
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text(
                'Начать'
              ),
              onPressed: () {
                DateTime currentDate = DateTime.now();
                int currentDateDay = currentDate.day;
                int currentDateMonth = currentDate.month;
                int currentDateYear = currentDate.year;
                String rawCurrentDate = '${currentDateDay}.${currentDateMonth}.${currentDateYear}';
                handler.updateExerciseIndicators(1, rawCurrentDate, exerciseType, '00:00:00', true);
                Navigator.pushNamed(
                  context,
                  '/exercise/started',
                  arguments: {
                    'exerciseType': exerciseType
                  }
                );
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
                    125, 25
                  )
                )
              )
            )
          ]
        )
      ],
    );
  }
}

class RecordStartedExerciseActivity extends StatefulWidget {

  const RecordStartedExerciseActivity({Key? key}) : super(key: key);

  @override
  State<RecordStartedExerciseActivity> createState() => _RecordStartedExerciseActivityState();

}

class _RecordStartedExerciseActivityState extends State<RecordStartedExerciseActivity> {

  late DatabaseHandler handler;
  String exerciseType = 'Ходьба';
  var contextMenuBtns = {
    ''
  };
  bool isStarted = true;
  late Timer startedTimer;
  int startedTimerSeconds = 0;
  int startedTimerMinutes = 0;
  int startedTimerHours = 0;
  String stopWatchTitleSeparator = ':';
  int countSecondsInMinute = 60;
  int initialSeconds = 0;
  int countMinutesInHour = 60;
  int initialMinutes = 60;
  String oneCharPrefix = '0';
  String startTimerTitle = '00:00:00';

  startTimer() {
    setState(() {
      isStarted = true;
    });
  }

  void runStartedTimer() async {
    setState(() {
      isStarted = true;
      startedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        startedTimerSeconds++;
        bool isToggleSecond = startedTimerSeconds == countSecondsInMinute;
        if (isToggleSecond) {
          // setState(() {
            startedTimerSeconds = initialSeconds;
          // });
          startedTimerMinutes++;
          bool isToggleMinute = startedTimerMinutes == countMinutesInHour;
          if (isToggleMinute) {
            startedTimerMinutes = initialMinutes;
            startedTimerHours++;
          }
        }
        String updatedHoursText = '${startedTimerHours}';
        int countHoursChars = updatedHoursText.length;
        bool isAddHoursPrefix = countHoursChars == 1;
        if (isAddHoursPrefix) {
          updatedHoursText = oneCharPrefix + updatedHoursText;
        }
        String updatedMinutesText = '${startedTimerMinutes}';
        int countMinutesChars = updatedMinutesText.length;
        bool isAddMinutesPrefix = countMinutesChars == 1;
        if (isAddMinutesPrefix) {
          updatedMinutesText = oneCharPrefix + updatedMinutesText;
        }
        String updatedSecondsText = '${startedTimerSeconds}';
        int countSecondsChars = updatedSecondsText.length;
        bool isAddSecondsPrefix = countSecondsChars == 1;
        if (isAddSecondsPrefix) {
          updatedSecondsText = oneCharPrefix + updatedSecondsText;
        }
        String currentTime = updatedHoursText + ":" + updatedMinutesText + ":" + updatedSecondsText;
        setState(() {
          startTimerTitle = currentTime;
        });
        handler.updateExerciseIndicators(1, '00:00', exerciseType, currentTime, false);
        print('debug: $currentTime');

      });
    });
  }

  stopTimer() {
    startedTimer.cancel();
    setState(() {
      isStarted = false;
    });
  }

  completeExercise(context) {
    stopTimer();
    DateTime pickedDate = DateTime.now();
    int pickedDateDay = pickedDate.day;
    int pickedDateMonth = pickedDate.month;
    int pickedDateYear = pickedDate.year;
    String rawDate = '${pickedDateDay}.${pickedDateMonth}.${pickedDateYear}';
    handler.addNewExerciseRecord(exerciseType, rawDate, startTimerTitle);
    handler.updateExerciseIndicators(0, '00:00', exerciseType, startTimerTitle, false);
    Navigator.pushNamed(context, '/exercise/results');
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
    runStartedTimer();
  }

  @override
  Widget build(BuildContext context) {

    setState(() {
      final arguments = ModalRoute.of(context)!.settings.arguments as Map;
      if (arguments != null) {
        print(arguments['exerciseType']);
        exerciseType = arguments['exerciseType'];
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          exerciseType
        ),
        actions: [
          FlatButton(
            child: Icon(
                Icons.music_note
            ),
            onPressed: () {

            },
            textColor: Color.fromARGB(255, 255, 255, 255)
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
      body: Column(
        children: [
          Text(
            'Оставшееся время'
          ),
          Text(
            '10,0 км'
          ),
          LinearProgressIndicator(

          ),
          Column(
            children: [
              Container(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Длительность',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                  Color.fromARGB(255, 0, 0, 0)
                                :
                                  Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                          startTimerTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (
                              isStarted ?
                              Color.fromARGB(255, 0, 0, 0)
                                  :
                              Color.fromARGB(255, 175, 175, 175)
                            )
                          )
                        ),
                      ]
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Скорость',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                          '00:00:00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (
                              isStarted ?
                              Color.fromARGB(255, 0, 0, 0)
                                  :
                              Color.fromARGB(255, 175, 175, 175)
                            )
                          )
                        ),
                      ]
                    )
                  ]
                )
              ),
              Container(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Темп',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                          '00:00:00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (
                              isStarted ?
                              Color.fromARGB(255, 0, 0, 0)
                                  :
                              Color.fromARGB(255, 175, 175, 175)
                            )
                          )
                        ),
                      ]
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Подъем',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                          '00:00:00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (
                              isStarted ?
                              Color.fromARGB(255, 0, 0, 0)
                                  :
                              Color.fromARGB(255, 175, 175, 175)
                            )
                          )
                        ),
                      ]
                    )
                  ]
                )
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Калории',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                            '00:00:00',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                        ),
                      ]
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Расстояние',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: (
                                isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                                    :
                                Color.fromARGB(255, 175, 175, 175)
                              )
                            )
                          )
                        ),
                        Text(
                          '00:00:00',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (
                              isStarted ?
                                Color.fromARGB(255, 0, 0, 0)
                              :
                                Color.fromARGB(255, 175, 175, 175)
                            )
                          )
                        ),
                      ]
                    )
                  ]
                )
              )
            ]
          )
        ]
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {

              },
              child: Icon(
                Icons.lock
              )
            ),
            (!isStarted ?
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      runStartedTimer();
                    },
                    child: Text(
                      'Продолжить'
                    )
                  ),
                  TextButton(
                    onPressed: () {
                      completeExercise(context);
                    },
                    child: Text(
                      'Завершить'
                    )
                  ),
                ]
              )
            :
              TextButton(
                onPressed: () {
                  stopTimer();
                },
                child: Text(
                  'Пауза'
                )
              )
            ),
            TextButton(
              onPressed: () {

              },
              child: Icon(
                Icons.location_on
              )
            )
          ]
        )
      ],
    );
  }

}


class RecordExerciseResultsActivity extends StatefulWidget {

  const RecordExerciseResultsActivity({Key? key}) : super(key: key);

  @override
  State<RecordExerciseResultsActivity> createState() => _RecordExerciseResultsActivityState();

}

class _RecordExerciseResultsActivityState extends State<RecordExerciseResultsActivity> {

  late DatabaseHandler handler;
  String exerciseType = 'Ходьба';
  ImagePicker _picker = ImagePicker();
  late XFile? _image;
  var cameras;
  bool isTakePhoto = false;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  attachImages(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Добавление изображения'),
        content: Container(
          child: Column(
            children: [
              TextButton(
                child: Text(
                  'Выбрать изображение'
                ),
                onPressed: () {
                  getImage();
                }
              ),
              TextButton(
                child: Text(
                  'Сделать снимок'
                ),
                onPressed: () async {
                  /*
                  камера требует более высокий minSdkVersion
                  */
                  cameras = await availableCameras();
                  final firstCamera = cameras.first;
                  setState((){
                    isTakePhoto = true;
                  });

                }
              )
            ]
          )
        )
      )
    );
  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {

      });
    });
    _picker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          exerciseType
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Column(
        children: [
          Text(
            'вт, 22 февр.'
          ),
          Text(
            '16:27 - 16:27'
          ),
          Container(
            width: 1000,
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '0,0',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28
                      )
                    ),
                    Text(
                      ' км',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      )
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                    '00:00:12',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                      )
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        left: 15
                      ),
                      child: Text(
                        '-- км/ч',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        )
                      )
                    )
                  ]
                )
              ]
            )
          ),
          Container(
            width: 1000,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Время тренировки',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 175, 175, 175)
                            )
                          ),
                          Text(
                            '00:00:12',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            'Общее время',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 175, 175, 175)
                            )
                          ),
                          Text(
                            '00:00:12',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          )
                        ]
                      )
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Калории\nтренировки(ккал)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 175, 175, 175)
                            )
                          ),
                          Text(
                            '2',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18
                            )
                          )
                        ]
                      ),
                      Column(
                        children: [
                          Text(
                            'Всего калорий(ккал)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromARGB(255, 175, 175, 175)
                            )
                          ),
                          Text(
                              '2',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                              )
                          )
                        ]
                      )
                    ]
                  )
                ]
            )
          ),
          Container(
            width: 1000,
            padding: EdgeInsets.all(
              15
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            child: Row(
              children: [
                Icon(
                  Icons.linked_camera_outlined
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 15
                  ),
                  child: TextButton(
                    child: Text(
                      'Изображения',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 175, 175, 175)
                      )
                    ),
                    onPressed: () {
                      attachImages(context);
                    }
                  )
                )
              ]
            )
          ),
          Container(
            width: 1000,
            padding: EdgeInsets.all(
              15
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            child: Row(
              children: [
                Icon(
                  Icons.note_outlined
                ),
                Container(
                  margin: EdgeInsets.only(
                  left: 15
                ),
                child: Text(
                  'Заметки',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 175, 175, 175)
                  )
                )
              )
            ]
          )
        )
        ]
      )
    );
  }

}

class EditMyPageActivity extends StatefulWidget {

  const EditMyPageActivity({Key? key}) : super(key: key);

  @override
  State<EditMyPageActivity> createState() => _EditMyPageActivityState();

}

class _EditMyPageActivityState extends State<EditMyPageActivity> {

  late DatabaseHandler handler;
  String nickName = '';
  String activityLevel = 'Сидячий образ жизни';
  String activityLevelDesc = 'Обычные ежедневные нагрузки';
  ImagePicker _picker = ImagePicker();
  late XFile? _image;
  var cameras;
  bool isTakePhoto = false;
  CameraController? cameraController = null;
  late int selectedCameraIdx;
  late String imagePath;
  Gender selectedGender = Gender.none;
  String realSelectedGrowthPart = '0';
  String imaginarySelectedGrowthPart = '0';
  Gender initialGender = Gender.none;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController?.dispose();
    }

    // 3
    cameraController = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    // 4
    cameraController?.addListener(() {
      // 5
      if (mounted) {
        setState(() {});
      }

      if (cameraController!.value.hasError) {
        print('Camera error ${cameraController?.value.errorDescription}');
      }
    });

    // 6
    try {
      await cameraController?.initialize();
    } on CameraException catch (e) {
      print('camera exception: ${e}');
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onCapturePressed(context) async {
    try {
      // 1
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      // 2
      await cameraController?.takePicture();
      // 3
      /*Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewImageScreen(imagePath: path),
        ),
      );*/
    } catch (e) {
      print(e);
    }
  }

  setGender(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Выбор пола'),
        content: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.female,
                    groupValue: selectedGender,
                    onChanged: (value) {
                      selectedGender = value!;
                    }
                  ),
                  Text(
                    'Женский'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.male,
                    groupValue: selectedGender,
                    onChanged: (value) {
                      selectedGender = value!;
                    }
                  ),
                  Text(
                    'Мужской'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.other,
                    groupValue: selectedGender,
                    onChanged: (value) {
                      selectedGender = value!;
                    }
                  ),
                  Text(
                    'Другое'
                  )
                ]
              ),
              Row(
                children: [
                  Radio<Gender>(
                    value: Gender.undefined,
                    groupValue: selectedGender,
                    onChanged: (value) {
                      selectedGender = value!;
                    }
                  ),
                  Text(
                    'Не хочу указывать'
                  )
                ]
              ),
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                selectedGender = initialGender;
              });
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {
              return Navigator.pop(context, 'OK');
            },
            child: const Text('Готово')
          )
        ]
      )
    );
  }

  setGrowth(context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Рост'),
        content: Container(
          child: Row(
            children: [
              Container(
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
                      realSelectedGrowthPart = value;
                    });
                  }
                )
              ),
              TextField(
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
                    imaginarySelectedGrowthPart = value;
                  });
                }
              )
            ]
          )
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                selectedGender = Gender.none;
              });
              return Navigator.pop(context, 'Cancel');
            },
            child: const Text('Отмена')
          ),
          TextButton(
            onPressed: () {

            },
            child: const Text('Готово')
          )
        ]
      )
    );
  }

  setWeight(context) {

  }

  @override
  initState() {
    super.initState();
    this.handler = DatabaseHandler();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {
        this.handler.retrieveIndicators().then((indicators) {
          if (indicators.length >= 1) {
            Indicators indicatorsItem = indicators[0];
            Gender gender = Gender.none;
            if (indicatorsItem.gender == 'Мужской') {
              gender = Gender.male;
            } else if (indicatorsItem.gender == 'Женский') {
              gender = Gender.female;
            } else if (indicatorsItem.gender == 'Другое') {
              gender = Gender.other;
            } else if (indicatorsItem.gender == 'Не хочу указывать') {
              gender = Gender.undefined;
            }
            initialGender = gender;
            selectedGender = initialGender;
          }
        });
      });
    });
    _picker = ImagePicker();
    availableCameras().then((availableCameras) {

      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          // 2
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      // 3
      print('Error: $err.code\nError Message: $err.message');
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: (
        isTakePhoto ?
          AspectRatio(
            aspectRatio: cameraController!.value.aspectRatio,
            child: CameraPreview(
              cameraController!
            )
          )
        :
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/user_logo.png',
                    width: 1000,
                    height: 250
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Image.asset(
                        'assets/images/user_logo.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/images/user_logo.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/images/user_logo.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/images/user_logo.png',
                        width: 50,
                        height: 50,
                      ),
                      Image.asset(
                        'assets/images/user_logo.png',
                        width: 50,
                        height: 50,
                      ),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text(
                          'Галлерея'
                        ),
                        onPressed: () {
                          getImage();
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 0, 0, 0)
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 200, 200, 200)
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)
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
                      TextButton(
                        child: Text(
                          'Камера'
                        ),
                        onPressed: () {
                          // _onCapturePressed(context);
                          setState(() {
                            isTakePhoto = true;
                          });
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 0, 0, 0)
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 200, 200, 200)
                          ),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)
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
                    ]
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
                          'Псевдоним',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        TextField(
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
                              nickName = value;
                            });
                          }
                        )
                      ]
                    )
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
                        GestureDetector(
                          onTap: () {
                            setGender(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_circle
                              ),
                              Container(
                                child: Text(
                                  'Пол'
                                ),
                                margin: EdgeInsets.only(
                                  left: 15
                                )
                              )
                            ]
                          )
                        ),
                        GestureDetector(
                          onTap: () {
                            setGrowth(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.people
                              ),
                              Container(
                                child: Text(
                                  'Рост'
                                ),
                                margin: EdgeInsets.only(
                                  left: 15
                                )
                              )
                            ]
                          )
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.home
                            ),
                            Container(
                              child: Text(
                                '70 кг',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 200, 0)
                                )
                              ),
                              margin: EdgeInsets.only(
                                left: 15
                              )
                            )
                          ]
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.cake
                            ),
                            Container(
                              child: Text(
                                '22 нояб. 2000 г'
                              ),
                              margin: EdgeInsets.only(
                                left: 15
                              )
                            )
                          ]
                        ),
                      ]
                    )
                  ),
                  Text(
                    'Данные про пол, рост, вес и дату рождения\nиспользуются для расчета количества сожженных\n каллорий, оптимального потребления каллорий и\nдиапазона частоты пульса во время тренировки.\nВы можете не предоставлять эту информацию, но в этом случае рекомендации по здоровью будут менее\nточными.'
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
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 15
                          ),
                          child: Text(
                            'Уровень активности',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )
                          )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: activityLevel == 'Сидячий образ жизни' ? Color.fromARGB(255, 0, 200, 0) : Color.fromARGB(255, 225, 225, 225),
                                      borderRadius: BorderRadius.circular(100.0)
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: Color.fromARGB(255, 255, 255, 255)
                                    )
                                  ),
                                  onTap: () {
                                    setState(() {
                                      activityLevel = 'Сидячий образ жизни';
                                      activityLevelDesc = 'Обычные ежедневные нагрузки';
                                    });
                                  }
                                ),
                                Text(
                                  '1',
                                  textAlign: TextAlign.center
                                )
                              ]
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: activityLevel == 'Несущественная активность' ? Color.fromARGB(255, 0, 200, 0) : Color.fromARGB(255, 225, 225, 225),
                                      borderRadius: BorderRadius.circular(100.0)
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: Color.fromARGB(255, 255, 255, 255)
                                    )
                                  ),
                                  onTap: () {
                                    setState(() {
                                      activityLevel = 'Несущественная активность';
                                      activityLevelDesc = 'Обычные ежедневные нагрузки и 30-60 мин.\nумеренных ежедневных нагрузок(например ходьба\nсо скоростью 5-7 км/ч)';
                                    });
                                  }
                                ),
                                Text(
                                    '2',
                                    textAlign: TextAlign.center
                                )
                              ]
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: activityLevel == 'Активный' ? Color.fromARGB(255, 0, 200, 0) : Color.fromARGB(255, 225, 225, 225),
                                      borderRadius: BorderRadius.circular(100.0)
                                    ),
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.directions_walk,
                                      color: Color.fromARGB(255, 255, 255, 255)
                                    )
                                  ),
                                  onTap: () {
                                    setState(() {
                                      activityLevel = 'Активный';
                                      activityLevelDesc = 'Обычные ежедневные нагрузки и не менее 60 мин.\nумеренных ежедневных нагрузок';
                                    });
                                  }
                                ),
                                Text(
                                    '3',
                                    textAlign: TextAlign.center
                                )
                              ]
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  child:
                                    Container(
                                      decoration: BoxDecoration(
                                        color: activityLevel == 'Большая активность' ? Color.fromARGB(255, 0, 200, 0) : Color.fromARGB(255, 225, 225, 225),
                                        borderRadius: BorderRadius.circular(100.0)
                                      ),
                                      width: 50,
                                      height: 50,
                                      child: Icon(
                                        Icons.directions_run,
                                        color: Color.fromARGB(255, 255, 255, 255)
                                      )
                                    ),
                                    onTap: () {
                                      setState(() {
                                        activityLevel = 'Большая активность';
                                        activityLevelDesc = 'Обычные ежедневные нагрузки, а также не менее\n60 мин. умеренных ежедневных нагрузок и 60 мин.\nинтенсивных нагрузок. Вместо этого вы можете добавить к ыежедневным нагрузкам  120 мин.\nумеренных нагрузок.';
                                      });
                                    }
                                  ),
                                Text(
                                  '4',
                                  textAlign: TextAlign.center
                                )
                              ]
                            ),
                          ]
                        ),
                        Text(
                          activityLevel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                        ),
                        Text(
                          activityLevelDesc,
                          textAlign: TextAlign.center
                        )
                      ]
                    )
                  )
                ]
              )
            )
          )
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text(
                'Отмена'
              ),
              onPressed: () {
                setState(() {
                  bool isNotTakePhoto = !isTakePhoto;
                  if (isNotTakePhoto) {
                    Navigator.pushNamed(context, '/main');
                  }
                  isTakePhoto = false;
                });
              }
            ),
            TextButton(
              child: Text(
                'Сохранить'
              ),
              onPressed: () {
                setState(() {
                  bool isNotTakePhoto = !isTakePhoto;
                  if (isNotTakePhoto) {
                    String gender = '';
                    bool isMale = selectedGender == Gender.male;
                    bool isFemale = selectedGender == Gender.female;
                    bool isOther = selectedGender == Gender.other;
                    bool isUndefined = selectedGender == Gender.undefined;
                    if (isMale) {
                      gender = 'Мужской';
                    } else if (isFemale) {
                      gender = 'Женский';
                    } else if (isOther) {
                      gender = 'Другое';
                    } else if (isUndefined) {
                      gender = 'Не хочу указывать';
                    }
                    double growth = 0.0;
                    double weight = 0.0;
                    handler.updateAccountIndicators(gender, growth, weight);
                    Navigator.pushNamed(context, '/main');
                  }
                });
              }
            )
          ]
        )
      ],
    );
  }

}

class RecordBodyActivity extends StatefulWidget {

  const RecordBodyActivity({Key? key}) : super(key: key);

  @override
  State<RecordBodyActivity> createState() => _RecordBodyActivityState();

}

class _RecordBodyActivityState extends State<RecordBodyActivity> {

  late DatabaseHandler handler;
  String fat = '';
  String musculature = '';
  String marks = '';

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
          'Запись данных о весе'
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      body: Column(
        children: [
          TextButton(
            onPressed: () {

            },
            child: Text(
              'ср, 23 февраля 16:35'
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
                  'Вес(кг)'
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        height: 50,
                        child: Column(
                          children: []
                        )
                      )
                    ),
                    Column(
                      children: [
                        Text(
                          ':'
                        )
                      ]
                    ),
                    Column(
                      children: [

                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Text(
            'Указанный вес будет также выводиться в профиле\nпользователя.'
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Телесный жир.'
                    ),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          child: TextField(
                            decoration: new InputDecoration.collapsed(
                              hintText: '',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0
                                )
                              )
                            ),
                            onChanged: (value) {
                              setState(() {
                                fat = value;
                              });
                            }
                          ),
                          margin: EdgeInsets.only(
                            right: 15
                          )
                        ),
                        Text(
                          '%'
                        )
                      ]
                    )
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Скелетн. мускулат.'
                    ),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          child: TextField(
                            decoration: new InputDecoration.collapsed(
                              hintText: '',
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0
                                )
                              )
                            ),
                            onChanged: (value) {
                              setState(() {
                                musculature = value;
                              });
                            }
                          ),
                          margin: EdgeInsets.only(
                            right: 15
                          )
                        ),
                        Text(
                          'кг'
                        )
                      ]
                    )
                  ]
                )
              ]
            )
          ),
          Text(
            ''
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
            child: Row(
              children: [
                Icon(
                  Icons.note_alt
                ),
                Container(
                  width: 300,
                  child: TextField(
                    decoration: new InputDecoration.collapsed(
                      hintText: 'Заметки',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1.0
                        )
                      )
                    ),
                    onChanged: (value) {
                      setState(() {
                        marks = value;
                      });
                    }
                  ),
                  margin: EdgeInsets.only(
                    left: 15
                  )
                )
              ]
            )
          )
        ]
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              child: Text(
                'Отмена',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                )
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/body');
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 0, 0, 0)
                )
              )
            ),
            TextButton(
              child: Text(
                'Сохранить',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                )
              ),
              onPressed: () {
                int parsedMusculature = int.parse(musculature);
                int parsedFat = int.parse(fat);
                DateTime date = DateTime.now();
                int dateDay = date.day;
                int dateMonth = date.month;
                int dateYear = date.year;
                String parsedDate = '${dateDay}.${dateMonth}.${dateYear}';
                handler.addNewBodyRecord(marks, parsedMusculature, parsedFat, 0.0, parsedDate);
                Navigator.pushNamed(context, '/body');
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(
                  Color.fromARGB(255, 0, 0, 0)
                )
              )
            )
          ]
        )
      ],
    );
  }
}

class SettingsActivity extends StatefulWidget {

  const SettingsActivity({Key? key}) : super(key: key);

  @override
  State<SettingsActivity> createState() => _SettingsActivityState();

}

class _SettingsActivityState extends State<SettingsActivity> {

  late DatabaseHandler handler;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Настройки Softtrack Здоровье'
        )
      ),
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
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Softtrack аккаунт',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              '**********@gmail.com',
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                            Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 0, 0, 0)
                            )
                          ]
                        )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Синхронизация с Softtrack Здоровье',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Text(
                                  'Включите, чтобы завершить\nвосстановление данных.',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 200, 0)
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            ),
                            Switch(
                              onChanged: (value) {

                              },
                              value: false
                            )
                          ]
                        )
                      ]
                    ),
                  ]
                )
              ),
              Text(
                'Общие',
                style: TextStyle(
                  color: Color.fromARGB(255, 175, 175, 175)
                )
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
                      GestureDetector(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Единицы измерения',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/settings/general/measure');
                        }
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Макретинговые уведомления',
                                    style: TextStyle(
                                      fontSize: 18
                                    )
                                  ),
                                  Text(
                                    'Получение уведомлений от Softtrack\nЗдоровье.',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 175, 175, 175)
                                    )
                                  ),
                                  Divider(
                                      thickness: 1,
                                      color: Color.fromARGB(255, 0, 0, 0)
                                  )
                                ]
                              ),
                              Switch(
                                onChanged: (value) {

                                },
                                value: false
                              )
                            ]
                          )
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                Text(
                                  'Подключенные службы',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Text(
                                  'Синхронизация данных Softtrack Здоровье с учетными\nзаписямисторонних веб-сервисов',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 175, 175, 175)
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                         ]
                        )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Служба персонализации',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Text(
                                  'Получайте персонализированное содержимое с\nучетом характера использования телефона',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 175, 175, 175)
                                  )
                                ),
                                Text(
                                  'Включено',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 200, 0)
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        )
                      ]
                    )
                  ]
                )
              ),
              Text(
                'Together',
                style: TextStyle(
                  color: Color.fromARGB(255, 175, 175, 175)
                )
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
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Получать приглашения от',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Text(
                                  'Друзья',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 200, 0)
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            ),
                          ]
                        ),
                        Row(
                          children: [
                            Text(
                                'Поиск друзей и управление',
                                style: TextStyle(
                                    fontSize: 18
                                )
                            )
                          ]
                        )
                      ]
                  )
              ),
              Text(
                'Дополнительно',
                style: TextStyle(
                  color: Color.fromARGB(255, 175, 175, 175)
                )
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Автоопределение тренировок',
                                    style: TextStyle(
                                      fontSize: 18
                                    )
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)
                                  )
                                ]
                              ),
                              Switch(
                                onChanged: (value) {

                                },
                                value: false
                              )
                            ]
                          )
                        ]
                      ),
                    ]
                  )
              ),
              Text(
                'Конциденциальность',
                style: TextStyle(
                  color: Color.fromARGB(255, 175, 175, 175)
                )
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
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Уведомление о конфиденциальности',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Разрешения на доступ к данным',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Text(
                                  'Разрешите функциям Softtrack Здоровье и\nсторонним приложениям считывать и записывать\nопределенную информацию',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 175, 175, 175)
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        ),
                        GestureDetector(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Номер телефона',
                                    style: TextStyle(
                                      fontSize: 18
                                    )
                                  ),
                                  Divider(
                                    thickness: 1,
                                    color: Color.fromARGB(255, 0, 0, 0)
                                  )
                                ]
                              )
                            ]
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/settings/privacy/phone');
                          }
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Загрузка личных данных',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Удаление личных данных',
                                  style: TextStyle(
                                    fontSize: 18
                                  )
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Color.fromARGB(255, 0, 0, 0)
                                )
                              ]
                            )
                          ]
                        ),
                      ]
                  )
              ),
              Text(
                  'Информация',
                  style: TextStyle(
                      color: Color.fromARGB(255, 175, 175, 175)
                  )
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
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'О Softtrack Здоровье',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 0, 0, 0)
                            )
                          ]
                        )
                      ]
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Свяжитесь с нами',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Divider(
                              thickness: 1,
                              color: Color.fromARGB(255, 0, 0, 0)
                            )
                          ]
                        )
                      ]
                    )
                  ]
                )
              ),
            ]
          )
        )
      ),
      backgroundColor: Color.fromARGB(255, 225, 225, 225)
    );
  }

}

class SettingsPrivacyPhoneActivity extends StatefulWidget {

  const SettingsPrivacyPhoneActivity({Key? key}) : super(key: key);

  @override
  State<SettingsPrivacyPhoneActivity> createState() => _SettingsPrivacyPhoneActivityState();

}

class _SettingsPrivacyPhoneActivityState extends State<SettingsPrivacyPhoneActivity> {

  String phoneNumber = '99999999999';

  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      phoneNumber = (await MobileNumber.mobileNumber)!;
      print('phoneNumber: ${phoneNumber}');
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }
  }

  @override
  initState() {
    super.initState();
    MobileNumber.listenPhonePermission((isPermissionGranted) {
      if (isPermissionGranted) {
        initMobileNumberState();
      }
    });
    initMobileNumberState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 225, 225, 225),
      appBar: AppBar(
        title: Text(
          'Номер телефона'
        )
      ),
      body: Column(
        children: [
          Text(
            'Приложение Softtrack Здоровье используе\n ваш номер телефона, чтобы помочь друзьям\nнаходить вас и приглашать в соревнования.'
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255)
            ),
            child: Column(
              children: [
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 28
                  )
                ),
                Text(
                  'Этот номеер можно изменить в разделе\n\"Двухэтапная проверка\" в Softtrack аккаунт.'
                ),
                Text(
                  'Softtrack аккаунт',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  )
                )
              ]
            ),
            padding: EdgeInsets.all(
              15
            ),
            margin: EdgeInsets.symmetric(
              vertical: 15
            )
          )
        ]
      )
    );
  }
}

class SettingsGeneralMeasureActivity extends StatefulWidget {

  const SettingsGeneralMeasureActivity({Key? key}) : super(key: key);

  @override
  State<SettingsGeneralMeasureActivity> createState() => _SettingsGeneralMeasureActivityState();

}

class _SettingsGeneralMeasureActivityState extends State<SettingsGeneralMeasureActivity> {

  var growthContextMenuBtns = {
    'см',
    'фт., дюйм'
  };
  var weightContextMenuBtns = {
    'кг',
    'фунт'
  };
  var tempContextMenuBtns = {
    '°C',
    '°F'
  };
  var distanseContextMenuBtns = {
    'км',
    'ми, фт'
  };
  var sugarContextMenuBtns = {
    'мг/дл',
    'ммоль/л'
  };
  var pressureContextMenuBtns = {
    'мм рт. ст.',
    'кПа'
  };
  var hba1cContextMenuBtns = {
    '%',
    'ммоль/моль'
  };
  var waterContextMenuBtns = {
    'мл',
    'жидк. унц.'
  };
  String growthMeasure = 'см';
  String weightMeasure = 'кг';
  String tempMeasure = '°C';
  String distanseMeasure = 'км';
  String sugarMeasure = 'ммоль/л';
  String pressureMeasure = 'мм рт. ст.';
  String hba1cMeasure = '%';
  String waterMeasure = 'мл';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 225, 225, 225),
        appBar: AppBar(
          title: Text(
            'Единицы измерения'
          )
        ),
        body: Column(
          children: [
            Text(
              'Приложение Softtrack Здоровье используе\n ваш номер телефона, чтобы помочь друзьям\nнаходить вас и приглашать в соревнования.'
            ),
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255)
              ),
              child: Column(
                children: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return growthContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        growthMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Рост',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              growthMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return weightContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        weightMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Вес',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              weightMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return tempContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        tempMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Температура',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              tempMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            )
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return distanseContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        distanseMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Расстояние',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              distanseMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return sugarContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        sugarMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Сахар крови',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              sugarMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return pressureContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        pressureMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Кровянное давление',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              pressureMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return hba1cContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        hba1cMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'HbA1c',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              hba1cMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) {
                      return waterContextMenuBtns.map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice)
                        );
                      }).toList();
                    },
                    onSelected: (menuItemName) {
                      setState(() {
                        waterMeasure = menuItemName;
                      });
                    },
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Объем выпиваемой воды',
                              style: TextStyle(
                                fontSize: 18
                              )
                            ),
                            Text(
                              waterMeasure,
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 200, 0)
                              )
                            ),
                          ]
                        )
                      ]
                    )
                  )
                ]
              ),
              padding: EdgeInsets.all(
                15
              ),
              margin: EdgeInsets.symmetric(
                vertical: 15
              ),
            )
          ]
        )
    );
  }
}

class NotificationsActivity extends StatefulWidget {

  const NotificationsActivity({Key? key}) : super(key: key);

  @override
  State<NotificationsActivity> createState() => _NotificationsActivityState();

}

class _NotificationsActivityState extends State<NotificationsActivity> {

  @override
  initState() {
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Уведомления'
        )
      ),
      body: Column(
        children: [

        ]
      )
    );
  }
}

class ForYouActivity extends StatefulWidget {

  const ForYouActivity({Key? key}) : super(key: key);

  @override
  State<ForYouActivity> createState() => _ForYouActivityState();

}

class _ForYouActivityState extends State<ForYouActivity> {

  @override
  initState() {
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
                'Для вас'
            )
        ),
        body: Column(
            children: [

            ]
        )
    );
  }
}

class EventsActivity extends StatefulWidget {

  const EventsActivity({Key? key}) : super(key: key);

  @override
  State<EventsActivity> createState() => _EventsActivityState();

}

class _EventsActivityState extends State<EventsActivity> {

  @override
  initState() {
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'События'
        )
      ),
      body: Column(
        children: [

        ]
      )
    );
  }
}