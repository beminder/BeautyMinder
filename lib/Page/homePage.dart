import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class homePage extends StatefulWidget{
  const homePage({Key? key}) : super(key: key);

  @override
  _homePage createState() => _homePage();

}

class _homePage extends State<homePage>{

  @override
  Widget build(BuildContext context){
  return Scaffold(
    body: Text('hello'),
  );
  }
}