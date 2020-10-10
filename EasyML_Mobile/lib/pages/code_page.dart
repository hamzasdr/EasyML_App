import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/gml.dart';
import 'package:flutter_highlight/themes/idea.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:path/path.dart';

class CodePage extends StatefulWidget {
  Model model;
  CodePage({@required this.model});
  @override
  _CodePageState createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  static const bool LIGHT = false, DARK = true;
  bool _theme = LIGHT;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Code for ${widget.model.name}", style: TextStyle(fontSize: 16), maxLines: 2,),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: Size(0, 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Switch(
                      onChanged: (value){
                        setState(() {
                          _theme = value;
                        });
                      },
                      value: _theme,
                      activeColor: Theme.of(context).primaryColor,
                      activeTrackColor: Colors.black,
                      inactiveThumbColor: Theme.of(context).accentColor,
                      inactiveTrackColor: Colors.white,
                    ),
                    Text(_theme == LIGHT ? "Light" : "Dark", style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),),
                    SizedBox(height: 5,)
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.python, color: Theme.of(context).accentColor,),
                      SizedBox(height: 5,),
                      SizedBox(
                        width: 100,
                        child: Text("Save Python source code",
                          style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
                          textAlign: TextAlign.center,
                        )
                      )
                    ],
                  ),
                  onTap: () async {
                    Directory dir = await getApplicationDocumentsDirectory();
                    var tempDirectory = join(dir.path, '${widget.model.name}.py');
                    File file = File(tempDirectory);
                    await file.writeAsString(widget.model.code);
                    final params = SaveFileDialogParams(sourceFilePath: tempDirectory);
                    final filePath = await FlutterFileDialog.saveFile(params: params);
                    print(filePath);
                    await file.delete();
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.book, color: Theme.of(context).accentColor,),
                      SizedBox(height: 5,),
                      SizedBox(
                          width: 100,
                          child: Text("Save Jupyter Notebook",
                            style: TextStyle(color: Theme.of(context).accentColor, fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                      )
                    ],
                  ),
                  onTap: () async {
                    Directory dir = await getApplicationDocumentsDirectory();
                    var tempDirectory = join(dir.path, '${widget.model.name}.ipynb');
                    File file = File(tempDirectory);
                    await file.writeAsString(jsonEncode(
                      {
                        "cells": widget.model.codeBlocks.map((List<String> block) =>
                        {
                          "cell_type": "code",
                          "execution_count": null,
                          "metadata": {},
                          "outputs": [],
                          "source": block.where((line)=>line!='\n').toList()
                        }).toList(),
                        "metadata": {},
                        "nbformat": 4,
                        "nbformat_minor": 2
                      }
                    ));
                    final params = SaveFileDialogParams(sourceFilePath: tempDirectory);
                    final filePath = await FlutterFileDialog.saveFile(params: params);
                    print(filePath);
                    await file.delete();
                  },
                ),
              )
            ]
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).accentColor,),
          onPressed: () => Navigator.pop(context),
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: HighlightView(
          widget.model.code,
          theme: _theme == LIGHT ? ideaTheme : gmlTheme,
          language: 'python',
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
