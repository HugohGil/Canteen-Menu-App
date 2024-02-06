import 'package:flutter/material.dart';
import 'package:tp2_am2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;



class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);

  static const String routeName = '/Edit';

  @override
  State<Edit> createState() => _EditState();
}


class _EditState extends State<Edit> {

  late final List<WeekDay?> list = ModalRoute.of(context)?.settings.arguments as List<WeekDay?>;
  late final WeekDay? original = list[0];
  late WeekDay? update = list[1];

  final TextEditingController _tecSoup = TextEditingController();
  final TextEditingController _tecFish = TextEditingController();
  final TextEditingController _tecMeat = TextEditingController();
  final TextEditingController _tecVegetarian = TextEditingController();
  final TextEditingController _tecDessert = TextEditingController();
  late final String a;

    @override
    void initState(){
      getWeekDay();
      super.initState();
    }

  late WeekDay? sharedWeekDay = WeekDay("","","","","","","");
  Future<void> getWeekDay() async {
    var prefs = await SharedPreferences.getInstance();

    setState((){
          final string = prefs.getString(original!.weekDay);
            if (string != null) {
              sharedWeekDay = WeekDay.fromJson(json.decode(string));
            }

      });
  }

  Future<void> setWeekDay(WeekDay dayToSend) async {
      setState(() {sharedWeekDay = dayToSend;});
      var prefs = await SharedPreferences.getInstance();
      prefs.setString(dayToSend.weekDay, json.encode(dayToSend));
  }

  static const String _menuPostUrl = 'http://192.168.1.143:8080/menu';


   Future<void> _sendFormData(String label) async{
        WeekDay formDay = WeekDay('', '', '', '', '', '', '');
        /* if(sharedWeekDay?.image != "") formDay.image = sharedWeekDay!.image;
        if(sharedWeekDay?.soup != "") formDay.soup = sharedWeekDay!.soup;
        if(sharedWeekDay?.fish != "") formDay.fish = sharedWeekDay!.fish;
        if(sharedWeekDay?.meat != "") formDay.meat = sharedWeekDay!.meat;
        if(sharedWeekDay?.vegetarian != "") formDay.vegetarian = sharedWeekDay!.vegetarian;
        if(sharedWeekDay?.desert != "") formDay.desert = sharedWeekDay!.desert; */

        formDay.weekDay = original!.weekDay;
        switch(label) {
          case "soup":
            sharedWeekDay!.soup = "";
            formDay.soup = original!.soup;
            formDay.fish = update!.fish;
            formDay.meat = update!.meat;
            formDay.vegetarian = update!.vegetarian;
            formDay.desert = update!.desert;
            break;
          case "fish":
            sharedWeekDay!.fish = "";
            formDay.fish = original!.fish;
            formDay.soup = update!.soup;
            formDay.meat = update!.meat;
            formDay.vegetarian = update!.vegetarian;
            formDay.desert = update!.desert;
            break;
          case "meat":
            sharedWeekDay!.meat = "";
            formDay.meat = original!.meat;
            formDay.fish = update!.fish;
            formDay.soup = update!.soup;
            formDay.vegetarian = update!.vegetarian;
            formDay.desert = update!.desert;
            break;
          case "vegetarian":
            sharedWeekDay!.vegetarian = "";
            formDay.vegetarian = original!.vegetarian;
            formDay.fish = update!.fish;
            formDay.meat = update!.meat;
            formDay.soup = update!.soup;
            formDay.desert = update!.desert;
            break;
          case "dessert":
            sharedWeekDay!.desert = "";
            formDay.desert = original!.desert;
            formDay.fish = update!.fish;
            formDay.meat = update!.meat;
            formDay.vegetarian = update!.vegetarian;
            formDay.soup = update!.soup;
            break;
          case "all":
            if (_tecSoup.text != '') formDay.soup = _tecSoup.text;
            if (_tecFish.text != '') formDay.fish = _tecFish.text;
            if (_tecMeat.text != '') formDay.meat = _tecMeat.text;
            if (_tecVegetarian.text != '')
              formDay.vegetarian = _tecVegetarian.text;
            if (_tecDessert.text != '') formDay.desert = _tecDessert.text;
            break;
        }

        Map data = {
          "img": formDay.image,
          "weekDay": formDay.weekDay,
          "soup": formDay.soup,
          "fish": formDay.fish,
          "meat": formDay.meat,
          "vegetarian": formDay.vegetarian,
          "desert": formDay.desert
        };

        final Map<String, String> headers = {'Content-Type': 'application/json; charset=UTF-8'};
        String formDayJson = jsonEncode(data);
        setWeekDay(formDay);
        debugPrint(formDayJson);
        try{
          http.Response response = await http.post(Uri.parse(_menuPostUrl), headers: headers, body: formDayJson);
          if (response.statusCode == HttpStatus.ok) {
            debugPrint(response.body);
          }
        } catch (ex) {
          debugPrint('Something went wrong: $ex');
        }
        setState(() {
              getWeekDay();
              update!.weekDay = formDay.weekDay;
              update!.image = formDay.image;
              update!.soup = formDay.soup;
              update!.fish = formDay.fish;
              update!.meat = formDay.meat;
              update!.desert = formDay.desert;
              update!.vegetarian = formDay.vegetarian;
        });
   }

  @override
  Widget build(BuildContext context) {

    update ??= WeekDay('', '', '', '', '', '', '');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
            'Editar Menu do Dia',
          style: TextStyle(
            color:Colors.indigo
          ),
        ),
      ),
      body: Center(
        child:SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('${original?.weekDay}', style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Soup', style: TextStyle(fontSize: 20), textAlign: TextAlign.justify),
                  if(update!.soup != original !.soup && update!.soup != '')
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Update: ${update!.soup}", style: const TextStyle(color: Colors.red), textAlign: TextAlign.justify),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Original: ${original!.soup}", textAlign: TextAlign.justify),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox( ///TextFormField
                        width: 250,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Soup:',
                            hintText: 'Soup of the day',
                            border: OutlineInputBorder(),
                          ),
                          controller: _tecSoup,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: () => _sendFormData("soup"),
                          child: const Text('Reset')
                      )
                    ],
                  ),
                ]
              ),
              const SizedBox(height: 9),
              const Divider(thickness: 2.0,),
              const SizedBox(height: 9),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Fish', style: TextStyle(fontSize: 20), textAlign: TextAlign.justify),
                    if(update!.fish != original !.fish && update!.fish != '')
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Update: ${update!.fish}", style: const TextStyle(color: Colors.red), textAlign: TextAlign.justify),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Original: ${original!.fish}", textAlign: TextAlign.justify),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox( ///TextFormField
                          width: 250,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Fish:',
                              hintText: 'Fish plate of the day',
                              border: OutlineInputBorder(),
                            ),
                            controller: _tecFish,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () => _sendFormData("fish"),
                            child: const Text('Reset')
                        )
                      ],
                    ),
                  ]
              ),
              const SizedBox(height: 9),
              const Divider(thickness: 2.0,),
              const SizedBox(height: 9),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Meat', style: TextStyle(fontSize: 20), textAlign: TextAlign.justify),
                    if(update!.meat != original !.meat && update!.meat != '')
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Update: ${update!.meat}", style: const TextStyle(color: Colors.red), textAlign: TextAlign.justify),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Original: ${original!.meat}", textAlign: TextAlign.justify),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox( ///TextFormField
                          width: 250,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Meat:',
                              hintText: 'Meat of the day',
                              border: OutlineInputBorder(),
                            ),
                            controller: _tecMeat,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () => _sendFormData("meat"),
                            child: const Text('Reset')
                        )
                      ],
                    ),
                  ]
              ),
              const SizedBox(height: 9),
              const Divider(thickness: 2.0,),
              const SizedBox(height: 9),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Vegetarian', style: TextStyle(fontSize: 20), textAlign: TextAlign.justify),
                    if(update!.vegetarian != original !.vegetarian && update!.vegetarian != '')
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Update: ${update!.vegetarian}", style: const TextStyle(color: Colors.red), textAlign: TextAlign.justify),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Original: ${original!.vegetarian}", textAlign: TextAlign.justify),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox( ///TextFormField
                          width: 250,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Vegetarian:',
                              hintText: 'Vegetarian option of the day',
                              border: OutlineInputBorder(),
                            ),
                            controller: _tecVegetarian,

                            //key: Key("$_inc"),
                            //initialValue: "$_inc",
                            ///onChanged: (value) => changeInc(int.tryParse(value) ?? 1),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () => _sendFormData("vegetarian"),
                            child: const Text('Reset')
                        )
                      ],
                    ),
                  ]
              ),
              const SizedBox(height: 9),
              const Divider(thickness: 2.0,),
              const SizedBox(height: 9),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dessert', style: TextStyle(fontSize: 20), textAlign: TextAlign.justify),
                    if(update!.desert != original !.desert && update!.desert != '')
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Update: ${update!.desert}", style: const TextStyle(color: Colors.red), textAlign: TextAlign.justify),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text("Original: ${original!.desert}", textAlign: TextAlign.justify),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox( ///TextFormField
                          width: 250,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Dessert:',
                              hintText: 'Dessert of the day',
                              border: OutlineInputBorder(),
                            ),
                            controller: _tecDessert,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                            onPressed: () => _sendFormData("dessert"),
                            child: const Text('Reset')
                      )
                    ],
                  ),
                ]
              ),
              const SizedBox(height: 9),
              const Divider(thickness: 2.0,),
              const SizedBox(height: 9),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                       onPressed: () {
                          _sendFormData("all");
                        },
                      child: const Text('Update')
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(original),
                      child: const Text('Return')
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ]
          ),
        )
      ),
    );
  }
}