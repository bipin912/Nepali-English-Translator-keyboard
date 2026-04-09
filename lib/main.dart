//This is the entry point of the app
//Flutter always looks for main() first - just like a book
//always starts at page 1.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



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

//TranslatorScreen - The main screen users see and interact with.
//Why StatefulWidget?
//Because this screen CHNAGES - the text the user types changes,
//the translation output changes, the loading spinner appears
//and dissapears. Any screen that changes needs StatefulWidget.
//StatelessWidget is only for screens that never change.

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

//_TranslatorScreenState - This is where the actual logic lives.class
// The underscore _ means it is private (only this file use it).class

class _TranslatorScreenState extends State<TranslatorScreen> {

  // VARIABLES
  //TextEditingController lets us read what the user typed
  //in the text box.
  final TextEditingController _inputController = TextEditingController();

  //This variable holds the translated English text.
  //It starts empty.
  String _translatedText = '';

  //This variable tracks whether we are currently translating.
  //true = show loading spinner, false = show result.
  bool _isLoading = false;

  //FUNCTIONS
  //This function runs when the user taps the Translate button.
  //Get API from GEMINI
  final String _apiKey = 'AIzaSyCvDqCyzBA1QAtocvVYWr2JTULCZxFzD64';

  //Unlike Claude, Gemini combines system + user message together.
  //so we build one combined prompt string.
  String _buildPrompt(String userInput) {
    return '''
    You are a Nepali-to-English translator.
    The user types Nepali sentences written in Roman/English letters (called Romanized Nepali).
    Your job is to translate these into natural, fluent English sentences.
    
    Rules:
    -Output ONLY the English translation. No explanations, no notes.
    -Preserve the tone: questions stay questions, casual stays casual.
    -Translate meaning, not word by word.
    
    Exmples:
    k xa khabar? -> How are you?
    ma thikai chu -> I am fine.
    khana khayou? -> Have you eaten?
    ramro chha -> It is good.
    tapai kahaa basnu huncha? -> Where do you live?
    ma school jaadai chu -> I am going to school.
    
   Now translate this:
   $userInput
    ''';
  }

  //_translate() - Calls the Gemini API

  //How GEMINI API works:
  //we send a POST request to Google's Gemini Server.
  //The URL includes our API key at the end.
  //The request body contains our prompt.
  //Gemini replies with the translation inside a nested JSON.


  //


  Future<void> _translate() async {
    final String inputText = _inputController.text;

    //If user typed nothing, do nothing
    if (inputText
        .trim()
        .isEmpty) return;

    //setState() tells Flutter "something changed, redraw the screen"
    setState(() {
      _isLoading = true;
      _translatedText = '';
    });

    try {
      //STEP A - BUILD THE GEMINI API URL
      //The API key goes directly in the URL for Gemini
      final String apiUrl =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey';

      //STEP B - SEND THE REQUEST
      final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },

          //Gemini expects this specific JSON structure:
          //{"contents": [ { "parts":[{"text": "your prompt"}]}]}
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text': _buildPrompt(inputText),
                  }
                ]
              }
            ],
            //These settings control how Gemini responds
            'generationConfig': {
              'temperature': 0.1, //low = more accurate, less creative
              'maxOutputTokens': 512,
            }
          })

      );

      //STEP C - READ THE RESPONSE
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        //Gemini response structure looks like this:
        //"candidates": [
        //{
        //  "contents" :{
        //          "parts": [
        //              {"text': "How are you?"}
        //       ]}}]}
        //so we dig into it step by step:

        final String translation =
        data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _isLoading = false;
          _translatedText = translation.trim();
        });
      }

      else {
        //show error if something went wrong
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        final String errorMessage =
            errorData['error']['message'] ?? 'Unknown error';


        setState(() {
          _isLoading = false;
          _translatedText = 'Error: $errorMessage';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _translatedText = 'Network error. Check Internet';
      });
    }
  }


//This function clears everything - input and output.
    void _clear() {
      setState(() {
        _inputController.clear();
        _translatedText = '';
        _isLoading = false;
      });
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(

        //APP BAR
        appBar: AppBar(
          backgroundColor: const Color(0xFF6C63FF),
          title: const Text(
            'Nepali Translator',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        //BODY
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20,),

              //LABEL
              const Text(
                  'Type Romanized Nepali:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  )
              ),

              const SizedBox(height: 10),

              //INPUT BOX
              TextField(
                controller: _inputController,
                maxLines: 4,
                minLines: 3,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'e.g. k xa khabar ?',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),

                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF6C63FF),
                        width: 2,
                      )
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 16,),

              //BUTTONS ROW

              Row(
                children: [
                  //TRANSLATE BUTTON
                  Expanded(
                      flex: 3,
                      child: ElevatedButton(onPressed: _translate,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C33FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)

                              )
                          ),
                          child: const Text(
                              'Translate',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )
                          )
                      )
                  ),

                  const SizedBox(width: 10,),

                  //CLEAR BUTTON
                  Expanded(
                      flex: 1,
                      child: ElevatedButton(onPressed: _clear,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0
                          ),
                          child: const Text('Clear')
                      )
                  )
                ],
              ),

              const SizedBox(height: 24),

              //OUTPUT BOX
              //Only shows when loading or when we have a result
              if(_isLoading || _translatedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color (0xFFF0EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6C63FF), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'English Translation:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C63FF),

                        ),
                      ),

                      const SizedBox(height: 12,),

                      //showing spinner while loading, show text when done
                      _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                          : Text(_translatedText,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF222222),
                            height: 1.5
                        ),
                      )

                    ],
                  ),

                ),
              const SizedBox(height: 30,
              ),

              //EXAMPLE CHIPS

              const Text(
                'Try an example:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _exampleChip('K xa khabar?'),
                  _exampleChip('ma thikai xu'),
                  _exampleChip('Khana khayou?')

                ],
              )
            ],
          ),
        ),

      );
    }


    //HELPER: builds one example chip
//When tapped, fills the input box with that text

    Widget _exampleChip(String text) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _inputController.text = text;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF6C63FF)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),
      );
    }

}