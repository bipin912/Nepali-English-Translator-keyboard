//This is the entry point of the app
//Flutter always looks for main() first - just like a book
//always starts at page 1.

import 'package:flutter/material.dart';

//main() is the first function flutter runs when the app starts
   void main(){
     runApp(const MyApp()); // This launches the app
}

//MyApp is the ROOT of your entire app.
//Think of it as the outer shell that wraps everything.

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
    //The name of your app (shows in task switcher)
    title: 'Nepali Translator',

    //Remove the debug banner in the top-right corner
    debugShowCheckedModeBanner: false,

    //The color theme of your app
  theme: ThemeData(
  colorScheme: ColorScheme.fromSeed( seedColor: Colors.deepPurple),
  useMaterial3: true,
),
  //This is the First Screen the user sees when they open the app.
  //We will build this screen next (Translator  Screen).
  home: const TranslatorScreen(),

    );
}
}

//What is TranslatoreScreen?
//This is the main screen of the app- the one with the
//text box, keyboard, and translation output.
//We are going to build this properly in next step
//for now it just shows a blank white screen so the app runs.

class TranslatorScreen extends StatelessWidget{
  const TranslatorScreen ({super.key});


  @override
  Widget build(BuildContext context){
    return const Scaffold(
    //Scaffold = the basic page layout (has background, appbar slot, body)
    body: Center(
    child: Text('App is working! Next step comming....')
    )
    );
}
}