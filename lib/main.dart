import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

String host=${environment.host};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Voting App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white,
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: Colors.grey),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color.fromARGB(255, 39, 37, 32),
            selectionHandleColor: Color.fromARGB(255, 59, 58, 53),
            selectionColor: Color.fromARGB(255, 151, 149, 143),
          )),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return Scaffold(
      body: const Center(
        child: Text(
          'Mawkhar Presbyterian Church App\n[Test App]',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Set<String> namesSet = Set<String>();
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [
    TextEditingController()
  ];
  final _codeController = TextEditingController();
  var storedCheckCode = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _clearNamesSet() {
    namesSet.clear();
  }

  FutureOr<bool?> checkCodeExists(String code) async {
    // make an http request to the server to check if the code already exists
    // return true if the code already exists, false otherwise
    // use http package to make request
    try{
      final response = //Uri.parse('http://+'host'+/codeExists/$code')
        await http.get(Uri.parse(
            '$host/codeExists/$code'));

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody;
    }
    else{
      return null;
    }
    } catch(e) {
      return null;
    }
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final namesList = _nameControllers
        .map((controller) => controller.text)
        .where((name) => name.isNotEmpty)
        .toList();
    await prefs.setStringList('names', namesList);
  }

  void _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNames = prefs.getStringList('names');
    if (savedNames != null) {
      _nameControllers.clear();
      for (var name in savedNames) {
        final controller = TextEditingController(text: name);
        _nameControllers.add(controller);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWidget(
      image: const AssetImage('assets/image1.jpeg'),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _nameControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: TextFormField(
                              cursorColor: const Color.fromARGB(213, 255, 255, 255),
                              style: const TextStyle(color: Color.fromARGB(213, 255, 255, 255)),
                              controller: _nameControllers[index],
                              decoration: InputDecoration(
                                labelText: 'Name ${index + 1}',
                                labelStyle: const TextStyle(color: Colors.white70),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 78, 96, 99)),
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 158, 158, 158)),
                                ),
                              ),
                              onChanged: (value) {
                                _saveData();
                              },
                              validator: (value) {
                                if (value != null && value.isEmpty) {
                                  return 'Please enter a name';
                                } else if (namesSet.contains(value)) {
                                  return 'Please enter a different name';
                                }
                                namesSet.add(value.toString());
                                return null;
                              },
                            ),
                          ),
                        ),
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: const Color.fromARGB(70, 180, 180, 180),
                            onPressed: () {
                              // Remove the name controller from the list
                              _saveData();
                              setState(() {
                                _nameControllers.removeAt(index);
                              });
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Add a button to add a new name to the list
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _nameControllers.add(TextEditingController());
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(50, 151, 151, 151)),
                    child: const Text('Add Name'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(50, 151, 151, 151)),
                    child: const Text('Clear All Names'),
                    onPressed: () {
                      setState(() {
                        _nameControllers.clear();
                        _nameControllers.add(TextEditingController());
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100.0),
                child: TextFormField(
                  cursorColor: const Color.fromARGB(213, 255, 255, 255),
                  style: const TextStyle(color: Color.fromARGB(255, 228, 228, 228)),
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center, // Set keyboard type to number
                  decoration: const InputDecoration(
                    label: Center(
                      child: Text('Code'),
                    ),
                    labelStyle: TextStyle(color: Color.fromARGB(220, 255, 255, 255)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 70, 70, 70)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 112, 112, 112)),
                    ),
                  ),
                  validator: (value) {
                    if(value == null || value.isEmpty){
                      return 'Empty Response';
                    }
                    else if (value.length != 6) {
                        return 'Please enter a 6-digit code';
                      }
                      else{
                        return null;
                      }
                    }
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Clear the namesSet
                  _clearNamesSet();

                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveData();
                    // Send the name and code to the backend server
                    var codeExists =
                        await checkCodeExists(_codeController.text);
                    if(codeExists == null){
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Backend seems to be offline...'),
                      ));
                      return;
                    }
                    if (!codeExists) {
                      // Show the floating dialogue
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            width: 200,
                            height: 200,
                            child: SimpleDialog(
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                                  child: Center(
                                      child: Text("Submitted!",
                                          style: TextStyle(fontSize: 20))),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    child: const Text("OK"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }

                    // Send the name and code to the backend server

                    if (codeExists) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('This code already exists'),
                      ));
                      return;
                    }
                    try {
                      final namesJson = jsonEncode({
                        'names': _nameControllers.map((c) => c.text).toList(),
                      });
                      //final response = 
                      await http.post(
                        Uri.parse(
                            '$host/vote'),
                        headers: {'Content-Type': 'application/json'},
                        body: namesJson,
                      );

                      // //check for duplicate names

                      // if (response.statusCode == 200) {
                      //   print('Success');
                      // } else {
                      //   print('Error');
                      // }
                    } catch (e) {
                      //print('Error: $e');
                    }
                  }
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor:  const Color.fromARGB(49, 99, 99, 99)),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundImageWidget extends StatelessWidget {
  final Widget child;
  final ImageProvider image;

  const BackgroundImageWidget({
    Key? key,
    required this.image,
    required this.child,
  }) : super(key: key);

  Widget buildBackground() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.black38, Color.fromARGB(242, 0, 0, 0)],
        begin: Alignment.center,
        end: Alignment.bottomCenter,
      ).createShader(bounds),
      blendMode: BlendMode.darken,
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.2),
                  BlendMode.darken,
                ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      buildBackground(),
      child,
    ]);
  }
}
