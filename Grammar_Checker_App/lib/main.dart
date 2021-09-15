import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart'as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bubble/bubble.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}
var newTexts = [];
var flagTexts = [];
var text = "";
var jsonList = [];
var suggestions = [];
var wordSuggestions = [];
var widgetSuggestions = [];
bool gramSynFlag = true;
var gram;
var syno;
var mostRecentJson = [];
var enteringFlag = false;
var mostRecentText = '';
var jsonList1 = [];
var jsonList2 = [];
var prevNav = 0;
String dictWord = '';
var word ='';
var HerokuUrl = 'https://flask-grammar-app.herokuapp.com';
AppBar app;
BuildContext con;
TextEditingController translateTextFieldController1 = new TextEditingController();
TextEditingController translateTextFieldController2 = new TextEditingController();
var dictSyn = [];
var dictAnt = [];
String _lang1 = "English", _lang2 = "English";
var translatedPhrase = "";
String prevPage = '';
var translator = GoogleTranslator();
var currentPage;
var langList = ['Afrikaans', 'Albanian', 'Amharic', 'Arabic', 'Armenian',
  'Azerbaijani', 'Basque', 'Belarusian', 'Bengali', 'Bosnian',
  'Bulgarian', 'Catalan', 'Cebuano', 'Chinese(Sf)',
  'Chinese(Tl)', 'Corsican', 'Croatian', 'Czech', 'Danish',
  'Dutch', 'English', 'Esperanto', 'Estonian', 'Finnish', 'French',
  'Frisian', 'Galician', 'Georgian', 'German', 'Greek', 'Gujarati',
  'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi', 'Hmong',
  'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Irish', 'Italian',
  'Japanese', 'Javanese', 'Kannada', 'Kazakh', 'Khmer',
  'Kinyarwanda', 'Korean', 'Kurdish', 'Kyrgyz', 'Lao', 'Latin',
  'Latvian', 'Lithuanian', 'Luxembourgish', 'Macedonian', 'Malagasy',
  'Malay', 'Malayalam', 'Maltese', 'Maori', 'Marathi', 'Mongolian',
  'Myanmar', 'Nepali', 'Norwegian', 'Nyanja',
  'Odia', 'Pashto', 'Persian', 'Polish',
  'Portuguese', 'Punjabi', 'Romanian', 'Russian',
  'Samoan', 'Scots Gaelic', 'Serbian', 'Sesotho', 'Shona', 'Sindhi',
  'Sinhala', 'Slovak', 'Slovenian', 'Somali', 'Spanish',
  'Sundanese', 'Swahili', 'Swedish', 'Tagalog', 'Tajik',
  'Tamil', 'Tatar', 'Telugu', 'Thai', 'Turkish', 'Turkmen',
  'Ukrainian', 'Urdu', 'Uyghur', 'Uzbek', 'Vietnamese', 'Welsh',
  'Xhosa', 'Yiddish', 'Yoruba', 'Zulu'];
var lang_codes = ['af', 'sq', 'am', 'ar', 'hy', 'az', 'eu', 'be', 'bn', 'bs', 'bg',
  'ca', 'ceb', 'zh', 'zh-TW', 'co', 'hr', 'cs', 'da', 'nl', 'en',
  'eo', 'et', 'fi', 'fr', 'fy', 'gl', 'ka', 'de', 'el', 'gu', 'ht',
  'ha', 'haw', 'he', 'hi', 'hmn', 'hu', 'is', 'ig', 'id', 'ga', 'it',
  'ja', 'jv', 'kn', 'kk', 'km', 'rw', 'ko', 'ku', 'ky', 'lo', 'la',
  'lv', 'lt', 'lb', 'mk', 'mg', 'ms', 'ml', 'mt', 'mi', 'mr', 'mn',
  'my', 'ne', 'no', 'ny', 'or', 'ps', 'fa', 'pl', 'pt', 'pa', 'ro',
  'ru', 'sm', 'gd', 'sr', 'st', 'sn', 'sd', 'si', 'sk', 'sl', 'so',
  'es', 'su', 'sw', 'sv', 'tl', 'tg', 'ta', 'tt', 'te', 'th', 'tr',
  'tk', 'uk', 'ur', 'ug', 'uz', 'vi', 'cy', 'xh', 'yi', 'yo', 'zu'];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Grammar App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => FeedBack(),
    ) ?? false;
  }
  @override
  Widget build(BuildContext context) {
    con = context;
    app =  AppBar(
      title: Text(widget.title),
    );
    gram =  new GrammarButton();
    syno = new SynonymsButton();
    return WillPopScope(
      onWillPop: _onWillPop,
      child: MainPage(),
    );
  }
}

class GrammarTextField extends StatefulWidget {
  GrammarTextField({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GrammarTextField createState() => _GrammarTextField();

}
TextField tf;
int count = 0;
class _GrammarTextField extends State<GrammarTextField> {

  var txt = MyTextController();


  void initState(){
    super.initState();
    txt.text = mostRecentText;
  }
  @override
  Widget build(BuildContext context)  {
    Color textColor = Colors.black;
    String x = "";
    tf = TextField(
        controller: txt,
        maxLines: 300,
        decoration: InputDecoration(hintText: 'Enter text'),

        style: TextStyle(color: textColor),
        onChanged: (value) {
          text =value;
            txt.text = value;
            txt..selection = TextSelection.collapsed(offset: txt.text.length);
            mostRecentText = value;
            mostRecentJson = [];
            for (var i=0; i<jsonList.length; i++){
              if (jsonList[i][0] + jsonList[i][1] <= mostRecentText.length){
                mostRecentJson.add(jsonList[i]);
              }
            }
          if (count <= 0) {
            count = 0;
            sendRequest(mostRecentText);
          }else{
            count--;
          }
          (con as Element).reassemble();
        }
    );


    return tf;
  }
}
var prevChildren = TextSpan(style: TextStyle(color: Colors.black), text: "");
class MyTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    if (count <=0){
      List<InlineSpan> children = [];
      if (newTexts.length != 0) {
        var newTex = [];
        var flagTex = [];
        for (var i=0; i<newTexts.length; i++){
          for (var j=0; j<newTexts[i].length; j++){
            newTex.add(newTexts[i][j]);
            flagTex.add(flagTexts[i]);
          }
        }
        mostRecentJson = [];
        for (var i=0; i<jsonList.length; i++){
          if (jsonList[i][0] + jsonList[i][1] <= mostRecentText.length){
            mostRecentJson.add(jsonList[i]);
          }
        }
        var len;
        if (mostRecentText.length > newTex.length){
          var i;
          for (i=0; i<newTex.length; i++){
            if (newTex[i] != mostRecentText[i]){
              break;
            }
          }
          len = i;
        }else{
          var i;
          for (i=0; i<mostRecentText.length; i++){
            if (newTex[i] != mostRecentText[i]){

              break;
            }
          }
          len = i;
        }
        for (var i = 0; i < len; i++) {
          if (flagTex[i] == true)
            children.add(TextSpan(
                style: TextStyle(color: (gramSynFlag) ? Colors.redAccent: Colors.orange), text: newTex[i]));
          else
            children.add(TextSpan(
                style: TextStyle(color: Colors.black), text: newTex[i]));
        }
        if (mostRecentText.length - len > 0){
          children.add(TextSpan(style: TextStyle(color: Colors.black), text: text.substring(len, mostRecentText.length)));

        }
      } else {
        children.add(
            TextSpan(style: TextStyle(color: Colors.black), text: mostRecentText));
      }
      prevChildren = TextSpan(style: style, children: children);
      return TextSpan(style: style, children: children);
    }

    else{
      return prevChildren;
    }
  }
}

class GrammarButton extends StatefulWidget {
  GrammarButton({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GrammarButton createState() => _GrammarButton();
}

class _GrammarButton extends State<GrammarButton> {
  @override
  Widget build(BuildContext context)  {
    return
      RaisedButton(
        onPressed: () { gramSynFlag = true; tf.onChanged(text);},
        textColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration:  BoxDecoration(
            gradient:(!gramSynFlag)? LinearGradient(
              colors: <Color>[


                Color(0xFF42A5F5),
                Color(0xFF1976D2),
                Color(0xFF0D47A1),
              ],
            ):LinearGradient(
              colors: <Color>[
                Colors.blue,
                Colors.blue,
                Colors.blue,
              ],
            ),
          ),
          padding: const EdgeInsets.all(10.0),

          child: const Text('Grammar', style: TextStyle(fontSize: 20)),
        ),
      );
  }
}


class SynonymsButton extends StatefulWidget {
  SynonymsButton({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SynonymsButton createState() => _SynonymsButton();
}

class _SynonymsButton extends State<SynonymsButton> {
  @override
  Widget build(BuildContext context)  {
    return RaisedButton(
      onPressed: () { gramSynFlag = false; tf.onChanged(mostRecentText); },
      textColor: Colors.white,
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration:  BoxDecoration(
          gradient:(gramSynFlag)? LinearGradient(
            colors: <Color>[
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFF42A5F5),
            ],
          ):LinearGradient(
            colors: <Color>[
              Colors.blue,
              Colors.blue,
              Colors.blue,
            ],
          ),
        ),
        padding: const EdgeInsets.all(10.0),
        child: const Text('Synonyms', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

Expanded createExpanded(BuildContext context){
  return Expanded(
    child: Container(
      width: MediaQuery.of(context).size.width,

      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: groupContainers(context),
          ),
        ),
      ),
      color: Colors.grey[100],
    ),
  );
}
List<Container> groupContainers(BuildContext context){
  var l = [];
  for (var i=0; i<mostRecentJson.length; i++){
    l.add(createContainer(i, context));
  }
  return l.map((x) => x as Container).toList();
}
Container createContainer(int no, BuildContext context){
  return  Container(
    width: MediaQuery.of(context).size.width - 20,
    padding: new EdgeInsets.all(10.0),
    child:Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      // color: Colors.grey,
      color: (gramSynFlag) ? Colors.redAccent:  Colors.deepOrangeAccent[200],
      elevation: 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.warning, size: 60),
            title: Text(mostRecentText.substring(mostRecentJson[no][0], mostRecentJson[no][0] + mostRecentJson[no][1]), style: TextStyle(fontSize: 30.0)),
          ),
          Wrap(
            runSpacing: 5.0,
            spacing: 5.0,
            children: groupRaisedButtons(no),
          ),
        ],
      ),
    ),
  );
}

List<RaisedButton> groupRaisedButtons(int no){
  List<RaisedButton> l = [];
  for (var i=0; i<mostRecentJson[no][2].length; i++){
    l.add(createRaisedButton(no, i));
  }
  return l;
}
RaisedButton createRaisedButton(var no, var i){
  return RaisedButton(
    child: Text(mostRecentJson[no][2][i]),
    onPressed: () {
      String newString;
      newString = mostRecentText.substring(0, mostRecentJson[no][0]) + mostRecentJson[no][2][i] + mostRecentText.substring(mostRecentJson[no][0] + mostRecentJson[no][1], mostRecentText.length);
      tf.onChanged(newString);
    },
  );
}
void sendRequest(var value) async {
  var url;
  if (gramSynFlag) {
    url = HerokuUrl+'/grammar?text=' + value;
  } else{
    url = HerokuUrl + '/synonyms?text='+value;
  }
  Response response = await get(url);
  jsonList = [];
  var document = parse(response.body);
  var jsonString = document.getElementsByTagName('body')[0].innerHtml;
  jsonList = json.decode(jsonString);
  newTexts = [];
  flagTexts = [];
  if (jsonList.length == 0){
  }else {
    var oldText = value;
    var startIndex = 0;
    for (var i=0; i<jsonList.length; i++){
      if (jsonList[i][0] - startIndex > 0) {
        newTexts.add(oldText.substring(startIndex, jsonList[i][0]));
        flagTexts.add(false);
      }
      newTexts.add(oldText.substring(jsonList[i][0], jsonList[i][0] + jsonList[i][1]));
      flagTexts.add(true);
      startIndex = jsonList[i][0] + jsonList[i][1];
    }
    if (oldText.length - (jsonList[jsonList.length-1][0] + jsonList[jsonList.length-1][1]) > 0 ) {
      newTexts.add(oldText.substring(
          jsonList[jsonList.length - 1][0] + jsonList[jsonList.length-1][1], oldText.length));
      flagTexts.add(false);
    }
  }
  count += 1;
  tf.onChanged(mostRecentText);
}
var speechInit = 0;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech;
  bool _isListening =false;
  String _textSpeech ='';
  IconButton ico;
  BuildContext b;
  void onListen() async {
    if (! _isListening) {
      bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError:$val')
      );
      if(available) {
        setState(() {
          _isListening =true;
        });
        _speech.listen(
            onResult: (val) => setState(() {
              _textSpeech = val.recognizedWords;
              text = text + _textSpeech.substring(speechInit, _textSpeech.length);
              speechInit = _textSpeech.length;
              tf.onChanged(text);
            })
        );
      }
    }else {
      setState(() {
        _isListening =false;
        speechInit = 0;
        _speech.stop();
        text = text + ' ';
        tf.onChanged(text);
        print("entered");
        ico.onPressed();
      });
    }
  }
  @override
  void initState(){
    super.initState();
    speechInit = 0;
    _speech =stt.SpeechToText();
  }
  @override
  Widget build(BuildContext context) {
    b = context;
    ico =  IconButton(

      onPressed: (){onListen();
      },
      color: Colors.white,
      icon: Icon(Icons.mic),
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    );
    return ico;
  }
}



class TextToSpeech extends StatefulWidget {
  @override
  _TextToSpeech createState() => _TextToSpeech();
}

class _TextToSpeech extends State<TextToSpeech> {
  IconButton ico;
  final FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    speak() async{
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.speak(mostRecentText);
    }
    ico = IconButton(
      onPressed:() => speak(),
      color: Colors.white,
      icon: Icon(Icons.volume_up),
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
    );

    return ico;
  }
}



class TranslateScreen extends StatefulWidget {
  @override
  _TranslateScreen createState() => _TranslateScreen();
}

class _TranslateScreen extends State<TranslateScreen> {
  @override
  Widget build(BuildContext context) {
    BuildContext c = context;

    return Column(
      //shrinkWrap: true,

      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              translateDropdown1(c),
              translateReverse(c),
              translateDropdown2(c),
            ],),),
        SingleChildScrollView(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            shrinkWrap: true,

            children:[
              Container(
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 20),
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5, bottom: 5),

                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height/2 - 165,

                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  border: Border(
                    left: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    right: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    bottom: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    top: BorderSide( //                    <--- top side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),

                child: TranslateTextField1(),
              ),

              FlatButton(
                color: Colors.white,
                onPressed:(){
                  int ind1;
                  int ind2;
                  int i=-1;
                  for (int i=0; i<langList.length; i++){
                    if (langList[i] == _lang1)
                      ind1 = i;
                    if (langList[i] == _lang2)
                      ind2 = i;
                  }
                  translator
                      .translate(translateTextFieldController1.text,
                      from: lang_codes[ind1], to: lang_codes[ind2])
                      .then((t) {
                    setState(() {
                      translateTextFieldController2.text = t.text;
                    });
                  });

                },


                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child:



                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Colors.blue,

                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),

                  padding: const EdgeInsets.all(10.0),

                  child: Center(child: const Text('Translate', style: TextStyle(fontSize: 20))),
                ),
              ),

              Container(

                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20, bottom: 20),
                padding: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5, bottom: 5),

                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height/2 - 165,

                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  border: Border(
                    left: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    right: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    bottom: BorderSide( //                   <--- left side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                    top: BorderSide( //                    <--- top side
                      color: Color(0xFFB3E5FC),
                      width: 2.0,
                    ),
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10)),

                ),

                child: TranslateTextField2(),
              ),
            ],),
        ),
      ],
    );
  }
}

Container translateDropdown1(BuildContext c){
  return
    Container(
      child:DropdownButton<String>(
        value: _lang1,
        items:  langList.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (String a) {print(a);
        _lang1 = a;
        (c as Element).reassemble();
        },
      ),);
}

Container translateDropdown2(BuildContext c){
  return
    Container(
      child:DropdownButton<String>(
        value: _lang2,

        items:  langList.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,

            child: new Text(value),
          );
        }).toList(),
        onChanged: (String a) {print(a);
        _lang2 = a;
        (c as Element).reassemble();
        },
      ),);
}
IconButton translateReverse(BuildContext c){
  return
    IconButton(

      onPressed: (){
        String a = _lang1, b = _lang2;
        _lang1 = b;
        _lang2 = a;
        (c as Element).reassemble();
      }
      ,
      color: Colors.blueAccent,
      iconSize: 40,
//icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      icon: Icon(Icons.compare_arrows_outlined),
      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
    );
}
TextField TranslateTextField1(){
  return TextField(controller: translateTextFieldController1,maxLines: 300,
    decoration: InputDecoration(hintText: 'Enter text to be translated'),
  );
}
TextField TranslateTextField2(){
  return TextField(controller: translateTextFieldController2, maxLines: 300,
    decoration: InputDecoration(hintText: 'Translated text will appear here'),
  );
}


class DictionaryScreen extends StatefulWidget {
  @override
  _DictionaryScreen createState() => _DictionaryScreen();
}

class _DictionaryScreen extends State<DictionaryScreen> {

  @override
  Widget build(BuildContext context) {
    BuildContext c = context;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children:[

        groupDictSyn(), groupDictAnt(),
        groupDictSent(),],
    );



  }
}


Container groupDictSyn(){

  var l = [];
  for (var i=0; i<dictSyn.length; i++){
    l.add(DictionarySynAnt(dictSyn[i]));
  }
  if (l.length > 0){
    return  Container(
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.centerLeft,
        child:Column(children: [Align(
            alignment: Alignment.centerLeft,
            child: Text("Synonyms:", style: TextStyle(fontSize: 23, color: Color(0xFF2962FF),), textAlign: TextAlign.left,)),
          groupSyn(),
        ],));}else{
    return Container();
  }

}
Container groupDictAnt(){

  var l = [];
  for (var i=0; i<dictAnt.length; i++){
    l.add(DictionarySynAnt(dictAnt[i]));
  }
  if (l.length > 0){
    return  Container(
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.centerLeft,
        child:Column(children: [Align(
            alignment: Alignment.centerLeft,
            child:Text("Antonyms:", style: TextStyle(fontSize: 23,color: Color(0xFF2962FF),),textAlign: TextAlign.left,)),
          groupAnt(),
        ],));}else{
    return Container();
  }

}
Container groupDictSent(){
  if (jsonList2.length>0){


    return Container(child:Column(children:[Container(
      padding: const EdgeInsets.all(5.0),
      alignment: Alignment.centerLeft,
      child:Text("Definitions:", style: TextStyle(fontSize: 23, color: Color(0xFF2962FF), fontFamily: 'Raleway'),),),
      groupSentences(),
    ],));
  }else{
    return Container();
  }
}

RaisedButton DictionarySynAnt(String s){
  return RaisedButton(
    onPressed:(){},
    color: Colors.grey,
    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
    padding: const EdgeInsets.all(1.0),
    child:Text(s, style: TextStyle(fontSize: 17, color:Colors.white)),);
}
Container groupSentences() {
  var l = [];
  for (var i = 0; i < jsonList2.length; i++) {
    l.add(getSegment(i));
  }

  return Container(child:Column(children: groupSegments(),));
}

Container getSegment(var a){
  var heading = DictHeading(a);
  Container b =Container( padding: const EdgeInsets.fromLTRB(30, 5, 5, 5),
    child:Column(children: groupDictSentences(a),),
  );
  Container c = Container(child:Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children:[heading, b]));
  return c;
}

Container DictHeading(var a){
  return Container( padding: const EdgeInsets.fromLTRB(20.0, 10.0, 5.0, 3.0),
    alignment: Alignment.centerLeft,
    child:Align( alignment: Alignment.centerLeft, child: Text(jsonList2[a][0], style: TextStyle(fontSize: 23, color: Color(0xFF1A237E)), textAlign: TextAlign.left ,),),);
}
List<Container> groupDictSentences(int no){
  var l = [];
  for (var i=1; i<jsonList2[no].length; i++){
    l.add(dictDefinitions(jsonList2[no][i][0], jsonList2[no][i][1]));
  }
  return l.map((x) => x as Container).toList();
}

Container dictDefinitions(var a, var b){
  return Container(

    alignment: Alignment.centerLeft,
    child: Column(
      children: [
        //Text(children:[], TextSpan(""), TextSpan(""))
        Align(

          alignment: Alignment.centerLeft,
          child: new RichText(
            text: new TextSpan(

              style: new TextStyle(
                fontSize: 14.0,
                color: Colors.black,
              ),
              children: <TextSpan>[
                new TextSpan(text: '\u2022 ',  style: new TextStyle(fontWeight: FontWeight.bold,  fontSize: 35), ),
                new TextSpan(text: a,style: new TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,

            child: Text("     "+b, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic), textAlign: TextAlign.left ,)),
      ],
    ),
  );
}

Wrap groupSyn(){

  var l = [];
  for (var i=0; i<dictSyn.length; i++){
    l.add(DictionarySynAnt(dictSyn[i]));
  }
  return Wrap(

    spacing: 5.0,
    runSpacing: 3.0,
    children: syndict(),);
}

Wrap groupAnt(){

  var l = [];
  for (var i=0; i<dictAnt.length; i++){
    l.add(DictionarySynAnt(dictAnt[i]));
  }
  return Wrap(

    spacing: 5.0,
    runSpacing: 3.0,
    children: antdict(),);
}

List<RaisedButton> syndict(){
  var l = [];
  for (var i=0; i<dictSyn.length; i++){
    l.add(DictionarySynAnt(dictSyn[i]));
  }
  return l.map((x) => x as RaisedButton).toList();;
}
List<RaisedButton> antdict(){
  var l = [];
  for (var i=0; i<dictAnt.length; i++){
    l.add(DictionarySynAnt(dictAnt[i]));
  }
  return l.map((x) => x as RaisedButton).toList();;
}
List<Container> groupSegments(){
  var l = [];
  for (var i = 0; i < jsonList2.length; i++) {
    l.add(getSegment(i));
  }
  return l.map((x) => x as Container).toList();
}









class Dictionary extends StatefulWidget {
  @override
  _Dictionary createState() => _Dictionary();
}

class _Dictionary extends State<Dictionary> {

  TextEditingController dictionaryController = TextEditingController();

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState(){
    super.initState();
    dictionaryController.text = dictWord;
    word = dictWord;
  }
  @override
  Widget build(BuildContext context) {
    speak() async{
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.speak(word);
    }

    return
      DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),

        ), child:ListView(
        shrinkWrap: true,

// alignment: Alignment.topCenter,
//child: Column(
//mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

         Row(children: [

           Container(
             width: MediaQuery.of(context).size.width - 50,
           child: TextField(
             controller: dictionaryController,

             decoration: InputDecoration(
               prefixIcon: Icon(Icons.search),
             ),

             onSubmitted: (value) async{
               word = value;
               dictionaryController.text = value;
               print(value);
               var url1 = HerokuUrl+'/words?text='+value;
               var url2 = HerokuUrl + '/definitions?text='+value;
               Response response1 = await get(url1);
               Response response2 = await get(url2);

               jsonList = [];
               var document1 = parse(response1.body);
               var document2 = parse(response2.body);
               var jsonString1 = document1.getElementsByTagName('body')[0].innerHtml;
               var jsonString2 = document2.getElementsByTagName('body')[0].innerHtml;
               dictWord = value;
               jsonList1 = json.decode(jsonString1);
               jsonList2 = json.decode(jsonString2);
               print(jsonList1);
               print(jsonList2);
               dictSyn = jsonList1[0];
               dictAnt = jsonList1[1];
               (context as Element).reassemble();
             },
           ),
           ), Container(
             child:  IconButton(
               onPressed:() => speak(),
               color: Colors.black,
               icon: Icon(Icons.volume_up, color: Colors.blue,),
               padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
             ),
           )
         ],),



          DictionaryScreen(),








        ],
//  ),
      ),
      );
  }
}




class Translate extends StatefulWidget {
  @override
  _Translate createState() => _Translate();
}

class _Translate extends State<Translate> {

  TextEditingController dictionaryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return
      DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),

        ), child:ListView(
        shrinkWrap: true,
    children: <Widget>[
          TranslateScreen(),
        ],
        //  ),
      ),
      );
  }
}

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {

  TextEditingController dictionaryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return
      DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),

        ),

        child:ListView(
          shrinkWrap: true,

          // alignment: Alignment.topCenter,
          //child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Color(0xFF0D47A1),
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
              ),
              width: MediaQuery.of(context).size.width,
              child:SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    new Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 0,
                      runSpacing: 5,
                      children: [
                        gram, syno,
                      ],
                    ),
                    new Wrap(
                      direction: Axis.horizontal,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 1,
                      runSpacing: 1,
                      children: [
                        SpeechScreen(),
                        IconButton(
                          onPressed: () {

                            prevNav = 4;
                            (con as Element).reassemble();
                          },
                          color: Colors.white,
                          icon: Icon(Icons.add_a_photo),
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        ),
                        TextToSpeech(),
                      ],
                    ),
                  ],
                ),),
            ),

            Container(
              width: MediaQuery.of(context).size.width,
              height: ((MediaQuery.of(context).size.height - 180)/2),
              color: Colors.grey[200],
              child:
              GrammarTextField(),
            ),
            SingleChildScrollView(child:  createExpanded(context),),

          ],
          //  ),
        ),

      );
  }
}






class FeedBack extends StatefulWidget {
  @override
  _FeedBack createState() => _FeedBack();
}

class _FeedBack extends State<FeedBack> {


  var myFeedbackText = "COULD BE BETTER";
  var sliderValue = 0.0;
  IconData myFeedback = FontAwesomeIcons.sadTear;
  Color myFeedbackColor = Colors.red;
  @override
  Widget build(BuildContext context) {
    return Center(child:SingleChildScrollView(
      child: Container(

        child: Align(
          child: Material(
            color: Colors.white,
            elevation: 14.0,
            borderRadius: BorderRadius.circular(24.0),
            shadowColor: Color(0x802196F3),
            child: Container(
                width: 350.0,
                height: 400.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Text(
                            myFeedbackText,
                            style: TextStyle(
                                color: Colors.black, fontSize: 22.0),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Icon(
                            myFeedback,
                            color: myFeedbackColor,
                            size: 100.0,
                          )),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(child: Slider(
                        min: 0.0,
                        max: 10.0,
                        divisions: 5,
                        value: sliderValue,
                        activeColor: Color(0xFF1565C0),
                        inactiveColor: Colors.blueGrey,
                        onChanged: (newValue) {
                          setState(() {
                            sliderValue = newValue;
                            if (sliderValue >= 0.0 && sliderValue <= 2.0) {
                              myFeedback = FontAwesomeIcons.sadTear;
                              myFeedbackColor = Colors.red;
                              myFeedbackText = "COULD BE BETTER";
                            }
                            if (sliderValue >= 2.1 && sliderValue <= 4.0) {
                              myFeedback = FontAwesomeIcons.frown;
                              myFeedbackColor = Colors.yellow;
                              myFeedbackText = "BELOW AVERAGE";
                            }
                            if (sliderValue >= 4.1 && sliderValue <= 6.0) {
                              myFeedback = FontAwesomeIcons.meh;
                              myFeedbackColor = Colors.amber;
                              myFeedbackText = "NORMAL";
                            }
                            if (sliderValue >= 6.1 && sliderValue <= 8.0) {
                              myFeedback = FontAwesomeIcons.smile;
                              myFeedbackColor = Colors.green;
                              myFeedbackText = "GOOD";
                            }
                            if (sliderValue >= 8.1 && sliderValue <= 10.0) {
                              myFeedback = FontAwesomeIcons.laugh;
                              myFeedbackColor = Colors.pink;
                              myFeedbackText = "EXCELLENT";
                            }
                          });
                        },
                      ),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        child: TextField(
                          maxLines: 2,
                          decoration: new InputDecoration(
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(
                                    color: Colors.blueGrey)),
                            hintText: 'Add Comment',
                          ),
                          style: TextStyle(fontSize: 18,),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Align(
                            // alignment: Alignment.bottomLeft,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  new BorderRadius.circular(30.0)),
                              color: Color(0xFF1565C0),
                              child: Text(
                                'Skip',
                                style: TextStyle(color: Color(0xffffffff)),
                              ),
                              onPressed: () { exit(0);},
                            ),
                          ),




                          Align(
                            //  alignment: Alignment.bottomRight,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  new BorderRadius.circular(30.0)),
                              color: Color(0xFF1565C0),
                              child: Text(
                                'Submit',
                                style: TextStyle(color: Color(0xffffffff)),
                              ),
                              onPressed: () { exit(0);},
                            ),
                          ),
                        ],),
                    ),
                  ],
                )),
          ),
        ),
      ),),);
  }
}


Widget chat(String message, int data) {
  return Padding(
    padding: EdgeInsets.all(10.0),
    child: Bubble(
        radius: Radius.circular(15.0),
        color: data == 0 ? Colors.deepPurpleAccent : Colors.blueAccent,
        elevation: 0.0,
        alignment: data == 0 ? Alignment.topLeft : Alignment.topRight,
        nip: data == 0 ? BubbleNip.leftBottom : BubbleNip.rightTop,
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[


              SizedBox(

                //   alignment: data == 0 ? Alignment.bottomLeft: Alignment.bottomRight,
                width: 10.0,
              ),


              Flexible(

                  child: Text(
                    message,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  )),
            ],
          ),
        )),
  );
}





class Chatbot extends StatefulWidget {
  @override
  _Chatbot createState() => _Chatbot();
}

class _Chatbot extends State<Chatbot> {

  List<Map> messsages = [];
  final messageInsert = TextEditingController();

  void response(query) async {
    var url = HerokuUrl+'/chatbot?text=' + query;
    Response response = await get(url);
    var document = parse(response.body);
    var jsonString = document.getElementsByTagName('body')[0].innerHtml;
    print("response is " + jsonString);
    setState(() {
      messsages.insert(0, {
        "data": 0,
        "message": jsonString
      });
    });
  }



  @override
  Widget build(BuildContext context) {

    return
      Container(
        child: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                    reverse: true,
                    itemCount: messsages.length,
                    itemBuilder: (context, index) => chat(
                        messsages[index]["message"].toString(),
                        messsages[index]["data"]))),
            Divider(
              height: 5.0,
              color: Colors.blue,
            ),
            Container(
              padding: EdgeInsets.only(left: 15.0, right: 15.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: TextField(
                        controller: messageInsert,
                        decoration: InputDecoration.collapsed(
                            hintText: "Send your message",
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0)),
                      )
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(

                        icon: Icon(

                          Icons.send,
                          size: 30.0,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          if (messageInsert.text.isEmpty) {
                            print("empty message");
                          } else {
                            setState(() {
                              messsages.insert(0,
                                  {"data": 1, "message": messageInsert.text});
                            });
                            response(messageInsert.text);
                            messageInsert.clear();
                          }
                        }),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            )
          ],
        ),



      );}
}

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => _MainPage();
}


class _MainPage extends State<MainPage> {
  int index = 0;
  int currentNavItem = 0;

  final _pageOptions = [
    Home(),
    Translate(),
    Dictionary(),

    Chatbot(),
    CameraScan()

  ];
  void onItemTapped(int index) {
    setState(() {
      print("index is ");
      print(index);
      currentNavItem = index;
      print("page opt " );
      currentPage = _pageOptions[index];
    });
  }
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        //return Container(child: Chatbot(),);
        return AlertDialog(
          title: new Text("Alert Dialog title"),
          content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new Chatbot(),
          ],
        );
      },
    );
  }

  @override
  void initState(){
    super.initState();
    this.index = 0;
    onItemTapped(0);
  }

  @override
  Widget build(BuildContext context) {
    if (prevNav == 4){

      return CameraScan();
    }
    else if (currentNavItem == 3){

      return

        Scaffold(
          appBar: AppBar(
              title: Text("Grammar App"),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),

                  onPressed: () {
                    setState(() {
                      currentNavItem = this.index;
                      this.index = index;
                      onItemTapped(index);
                    });

                    //
                  })),

          resizeToAvoidBottomInset: true,

          resizeToAvoidBottomPadding: false,
          body:  Chatbot(),


        );
    }
    else{
      return

        Scaffold(
          appBar:app,
          resizeToAvoidBottomInset: true,

          resizeToAvoidBottomPadding: false,
          body:  //Chatbot(),
          currentPage,
// Home(),
//  Translate(),
//Dictionary(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              setState(() {
                this.index = index;
                onItemTapped(index);
              });
            },
            items: <BottomNavigationBarItem>[
              new BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                title: new Text("Home"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.translate),
                title: new Text("Translate"),
              ),
              new BottomNavigationBarItem(
                icon: new Icon(Icons.menu_book),
                title: new Text("Dictionary"),
              ),

            ],
          ),
          floatingActionButton: FloatingActionButton(  onPressed:(){ setState(() {

            currentNavItem = 3;
            //onItemTapped(index);
          });
          },
            tooltip: 'Increment',
            child: Icon(Icons.message),),

        );
    }
  }
}


class ScannerUtils {
  ScannerUtils._();

  static Future<CameraDescription> getCamera(CameraLensDirection dir) async {
    return await availableCameras().then(
          (List<CameraDescription> cameras) => cameras.firstWhere(
            (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }

  static Future<dynamic> detect({
    @required CameraImage image,
    @required Future<dynamic> Function(FirebaseVisionImage image) detectInImage,
    @required int imageRotation,
  }) async {
    return detectInImage(
      FirebaseVisionImage.fromBytes(
        _concatenatePlanes(image.planes),
        _buildMetaData(image, _rotationIntToImageRotation(imageRotation)),
      ),
    );
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static FirebaseVisionImageMetadata _buildMetaData(
      CameraImage image,
      ImageRotation rotation,
      ) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map(
            (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  static ImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        assert(rotation == 270);
        return ImageRotation.rotation270;
    }
  }
}


class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.visionText);

  final Size absoluteImageSize;
  final VisionText visionText;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          paint.color = Colors.green;
          canvas.drawRect(scaleRect(element), paint);
        }

        paint.color = Colors.yellow;
        canvas.drawRect(scaleRect(line), paint);
      }

      paint.color = Colors.red;
      canvas.drawRect(scaleRect(block), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}


class CameraScan extends StatefulWidget {
  @override
  _CameraScan createState() => _CameraScan();
}


class _CameraScan extends State<CameraScan> {
  bool _isDetecting = false;

  VisionText _textScanResults;

  CameraLensDirection _direction = CameraLensDirection.back;

  CameraController _camera;

  final TextRecognizer _textRecognizer =
  FirebaseVision.instance.textRecognizer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    final CameraDescription description =
    await ScannerUtils.getCamera(_direction);

    _camera = CameraController(
      description,
      ResolutionPreset.high,
    );

    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      setState(() {
        _isDetecting = true;
      });
      ScannerUtils.detect(
        image: image,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
            (results) {
          setState(() {
            if (results != null) {
              setState(() {
                _textScanResults = results;
              });
            }
          });
        },
      ).whenComplete(() => _isDetecting = false);
    });
  }

  Future<VisionText> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _textRecognizer.processImage;
  }
  var newstr = '';
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _camera == null
              ? Container(
            color: Colors.black,
          )
              : Container(
              height: MediaQuery.of(context).size.height - 150,
              child: CameraPreview(_camera)),
              _buildResults(_textScanResults),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 2,
        onPressed: (){


          print("new str is " + newstr);

          for (var i=0; i<_textScanResults.blocks.length; i++){
            newstr += _textScanResults.blocks[i].text;
          }
          var a = newstr;
          newstr = '';
          tf.onChanged(a);
          prevNav = 0;
          (con as Element).reassemble();
        },
        child: Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }


  Widget _buildResults(VisionText scanResults) {
    CustomPainter painter;
    if (scanResults != null) {
      final Size imageSize = Size(
        _camera.value.previewSize.height - 100,
        _camera.value.previewSize.width,
      );
      painter = TextDetectorPainter(imageSize, scanResults);
      List<TextBlock> blocks = _textScanResults.blocks;
     return CustomPaint(
        painter: painter,
      );
    } else {
      return Container();
    }
  }

}