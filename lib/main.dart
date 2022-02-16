import 'package:flutter/material.dart';

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

  int currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            onTap: (index) {
              print('currentTabIndex: ${index}');
              setState(() {
                currentTab = index;
              });
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
            Column(

            ),
            Column(

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

            )
          ]
        )
      )
    );
  }
}
