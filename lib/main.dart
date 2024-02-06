import 'dart:convert';
import 'dart:io';
import 'dart:math' show sin, cos, sqrt, asin, pi, atan2;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'edit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      initialRoute: MyHomePage.routeName,
      routes: {
        MyHomePage.routeName : (context) => const MyHomePage(title: 'HomePage'),
        Edit.routeName : (context) => const Edit(),
      },
      debugShowCheckedModeBanner: false, // tirar a faixa de debug da aplicação
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  @override


  static const String routeName = '/';
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class WeekDay {
  WeekDay(this.weekDay, this.soup, this.fish, this.meat, this.vegetarian, this.desert, this.image);
  WeekDay.fromJson(Map<String, dynamic> json)
        : weekDay = json['weekDay'],
          soup = json['soup'],
          fish = json['fish'],
          meat = json['meat'],
          vegetarian = json['vegetarian'],
          desert = json['desert'],
          image = json['image'];
  Map<String, dynamic> toJson() => {
    'weekDay': weekDay,
    'soup': soup,
    'fish': fish,
    'meat': meat,
    'vegetarian': vegetarian,
    'desert': desert,
    'image': image,
  };
  String? image;
  String weekDay;
  String soup;
  String fish;
  String meat;
  String vegetarian;
  String desert;
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _menuRequestUrl = 'http://192.168.1.143:8080/menu';



  late bool isCloseToIsec = false;
  late double distance;


  double getDistanceBetweenLocations(double lat1, double lon1, double lat2, double lon2) {
    const double _earthRadius = 6371; // in kilometers
    lat1 = lat1 * pi / 180;
    lon1 = lon1 * pi / 180;
    lat2 = lat2 * pi / 180;
    lon2 = lon2 * pi / 180;

    double a = sin((lat2 - lat1) / 2) * sin((lat2 - lat1) / 2) +
        cos(lat1) * cos(lat2) * sin((lon2 - lon1) / 2) * sin((lon2 - lon1) / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = _earthRadius * c;

    return d * 1000; // convert to meters
  }

  void checkLocation() async {
    double latitude;
    double longitude;
    double referenceLatitude = 40.19196865;
    double referenceLongitude = -8.41186122234274;

    LocationData location = await Location().getLocation();
    latitude = location.latitude!;
    longitude = location.longitude!;
    // Calculate the distance between the two locations
    distance = getDistanceBetweenLocations(latitude, longitude, referenceLatitude, referenceLongitude);
    distance = (distance * 100).round() / 100;
    // Check if the distance is within the radius
    if (distance <= 200) {
      isCloseToIsec = true;
    } else {
      isCloseToIsec = false;
    }
  }

  int getWeekday() {
    final DateTime now = DateTime.now();
    int weekday = now.weekday;
    weekday--;
    print("Day : $weekday");
    switch (weekday) {
      case 5: return 0;
      case 6: return 0;
      default: return weekday;
    }
  }

  List<WeekDay?>? _weekDaysUpdate;
  List<WeekDay>? _weekDays;
  Future<void> getWeekDays() async {
     var prefs = await SharedPreferences.getInstance();
     //sharedWeekDay = original;
     setState((){
            for(int i = 0; i < _weekDays!.length;i++){
                 final string = prefs.getString(_weekDaysUpdate![i]!.weekDay);
                 if (string != null) {
                   _weekDaysUpdate![i] = WeekDay.fromJson(json.decode(string));
                 }
            }

       });
  }
  bool _fetchingData = false;
  Future<void> _fetchWeekDays() async {
    try{
      setState(() => _fetchingData = true);
      http.Response response = await http.get(Uri.parse(_menuRequestUrl), headers: {'Content-Type': 'application/json; charset=UTF-8'});
      if (response.statusCode == HttpStatus.ok) {
        debugPrint(response.body);
        List<WeekDay> weekDays = [];
        List<WeekDay?> weekDaysUpdate = [];
        final Map<String, dynamic> decodedData = json.decode(utf8.decode(response.bodyBytes));
        decodedData.forEach((key, value) {
            final Map<String, dynamic> original = value['original'];
            weekDays.add(WeekDay.fromJson(original));
            if(value['update'] != null){
              final Map<String, dynamic> update = value['update'];
              weekDaysUpdate.add(WeekDay.fromJson(update));
            }else{
              weekDaysUpdate.add(null);
            }
        });

        setState(() => _weekDays = weekDays);
        setState(() => _weekDaysUpdate = weekDaysUpdate);
      }
    } catch (ex) {
      debugPrint('Something went wrong: $ex');
    } finally {
      setState(() => _fetchingData = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children:[
             const SizedBox(width: 20),
             Padding(
               padding: const EdgeInsets.only(top: 15, bottom: 10),
               child: ElevatedButton(
                            onPressed: _fetchWeekDays,
                            child: const Text('Refresh'),
                ),
             ),
              const SizedBox(width: 20),
            if (_fetchingData) const CircularProgressIndicator(),
            if (!_fetchingData && _weekDays != null && _weekDays!.isNotEmpty)
                Expanded(
                    child: ListView.separated(
                      itemCount: _weekDays!.length,
                      separatorBuilder: (_, __) => const Divider(thickness: 2.0),
                      itemBuilder: (BuildContext context, int index) => ListTile(
                        title: Text(_weekDays![(index + getWeekday()) % _weekDays!.length].weekDay),
                        onTap: () {
                          checkLocation();
                          if(isCloseToIsec == true){
                            Navigator.pushNamed(context, '/Edit', arguments: [_weekDays![(index + getWeekday()) % _weekDays!.length],
                              _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]])
                                .then((value) => _fetchWeekDays());
                          }
                         else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("You are not close to the ISEC building. You are $distance meters away"),
                                  actions: [
                                    ElevatedButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length] != null)...{
                              if(_weekDays![(index + getWeekday()) % _weekDays!.length].soup != _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.soup)
                                Text("Soup: ${_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.soup}", style: const TextStyle(color: Colors.red),)
                              else
                                Text("Soup: ${_weekDays![(index + getWeekday()) % _weekDays!.length].soup}"),

                              if(_weekDays![(index + getWeekday()) % _weekDays!.length].fish != _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.fish)
                                Text("Fish: ${_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.fish}", style: const TextStyle(color: Colors.red),)
                              else
                                Text("Fish: ${_weekDays![(index + getWeekday()) % _weekDays!.length].fish}"),

                              if(_weekDays![(index + getWeekday()) % _weekDays!.length].meat != _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.meat)
                                Text("Meat: ${_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.meat}", style: const TextStyle(color: Colors.red),)
                              else
                                Text("Meat: ${_weekDays![(index + getWeekday()) % _weekDays!.length].meat}"),

                              if(_weekDays![(index + getWeekday()) % _weekDays!.length].vegetarian != _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.vegetarian)
                                Text("Vegetarian: ${_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.vegetarian}", style: const TextStyle(color: Colors.red),)
                              else
                                Text("Vegetarian: ${_weekDays![(index + getWeekday()) % _weekDays!.length].vegetarian}"),

                              if(_weekDays![(index + getWeekday()) % _weekDays!.length].desert != _weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.desert)
                                Text("Desert: ${_weekDaysUpdate![(index + getWeekday()) % _weekDays!.length]!.desert}", style: const TextStyle(color: Colors.red),)
                              else
                                Text("Desert: ${_weekDays![(index + getWeekday()) % _weekDays!.length].desert}")

                            }else...{
                              Text("Soup: ${_weekDays![(index + getWeekday()) % _weekDays!.length].soup}"),
                              Text("Fish: ${_weekDays![(index + getWeekday()) % _weekDays!.length].fish}"),
                              Text("Meat: ${_weekDays![(index + getWeekday()) % _weekDays!.length].meat}"),
                              Text("Vegetarian: ${_weekDays![(index + getWeekday()) % _weekDays!.length].vegetarian}"),
                              Text("Desert: ${_weekDays![(index + getWeekday()) % _weekDays!.length].desert}"),
                            },
                          ],
                        ),
                      ),
                    ),
                  )
          ],
        ),

      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
