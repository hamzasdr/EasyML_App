import 'dart:async';

import 'package:airship_flutter/airship_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:provider/provider.dart';

class TrainDialog extends StatefulWidget {
  // List<dynamic> columns;
  Model model;
  DataSet dataSet;
  TrainDialog({this.model, this.dataSet});
  @override
  _TrainDialogState createState() =>
      _TrainDialogState();
}

class _TrainDialogState
    extends State<TrainDialog> with TickerProviderStateMixin {
  Key _key = GlobalKey();
  Map<String, dynamic> yColumn;
  List<dynamic> toDropColumns = [];
  int _testSize = 20;
  Timer longPressTimer;
  bool _trainLoading = false;
  static const normalizationMethods = [null, 'min_max', 'std'];
  int _selectedNormalizationMethod = 0;

  @override
  void initState() {
    super.initState();
  }

  int setTestSize(int value) {
    value = value < 1 ? 1 : value > 99 ? 99 : value;
    setState(() {
      _testSize = value;
    });
    return _testSize;
  }

  @override
  Widget build(BuildContext context) {
    // final UserBloc userBloc = Provider.of<UserBloc>(context);
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Material(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(tag: widget.model.type.name, child: SizedBox()),
                Column(
                  children: <Widget>[
                    Text(
                      "Training",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height
//                      MediaQuery.of(context).size.height*0.5-calcBoxHeight(
//                        screenHeight: MediaQuery.of(context).size.height,
//                        context: _key.currentContext,
//                        insetsHeight: MediaQuery.of(context).viewInsets.bottom
//                      ),
                          ),
                      child: SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait) ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 15),
                                  widget.model.type.category != ModelCategory.CLUSTERING ?
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          "Test size",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(
                                          width: 5
                                        ),
                                        GestureDetector(
                                          child: Icon(Icons.help),
                                          onTap: (){
                                            Navigator.push(context, new HeroDialogRoute(
                                              builder: (BuildContext context) =>
                                                  InformationDialog(
                                                    tag: "train_comm_err",
                                                    text: "In supervised (regression or classification) training, the data is split into training data and testing data. "
                                                    "The trainig data is used to train the model. The testing data is used to test the model to determine how good was the training. "
                                                    "Recommended values for test size are between 20% and 35% of the whole data set.",
                                                    fontSize: 13.5,
                                                  )
                                            ));
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: Column(
                                      children: [
                                        Text(
                                          "How much of the data will you use for testing?",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        (_testSize > 35 || _testSize < 20) ? Text(
                                          "Try to keep the test size between 20% and 35%",
                                          style: TextStyle(fontSize: 10, color: Colors.redAccent),
                                        ) : SizedBox(),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setTestSize(_testSize - 1);
                                          },
                                          onLongPress: () {
                                            longPressTimer = Timer.periodic(
                                                Duration(milliseconds: 25), (timer) {
                                              setTestSize(_testSize - 1);
                                            });
                                          },
                                          onLongPressUp: () {
                                            if (longPressTimer != null)
                                              longPressTimer.cancel();
                                          },
                                          child: Icon(Icons.remove_circle),
                                        ),
                                        Container(
                                          width: 40,
                                          child: Text(
                                            "$_testSize%",
                                            style: TextStyle(fontSize: 16, color: (_testSize > 35 || _testSize < 20) ? Colors.redAccent : null),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setTestSize(_testSize + 1);
                                          },
                                          onLongPress: () {
                                            longPressTimer = Timer.periodic(
                                                Duration(milliseconds: 25), (timer) {
                                              setTestSize(_testSize + 1);
                                            });
                                          },
                                          onLongPressUp: () {
                                            if (longPressTimer != null)
                                              longPressTimer.cancel();
                                          },
                                          child: Icon(Icons.add_circle),
                                        )
                                      ],
                                    ),
                                  ):
                                  SizedBox(),
                                  ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          "Normalization Method",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          child: Icon(Icons.help),
                                          onTap: (){
                                            Navigator.push(context, new HeroDialogRoute(
                                                builder: (BuildContext context) =>
                                                    InformationDialog(
                                                      tag: "train_comm_err",
                                                      text: "Normalization is very important especially if your fields have different ranges.\n"
                                                          "Min/Max normalization scales the data such that the minimum value becomes 0 and the maximum value becomes 1.\n"
                                                          "Standard normalization removes the mean from the data then scales it to its variance.",
                                                      fontSize: 13.5,
                                                    )
                                            ));
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: Column(
                                      children: [
                                        Text(
                                          "What method of normalization are you going to use?",
                                          //  If the values in your data set are of many different ranges, it is very recommended to normalize your data
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () => setState((){_selectedNormalizationMethod = 0;}),
                                              child: AnimatedContainer(
                                                decoration: BoxDecoration(
                                                    color: _selectedNormalizationMethod == 0 ? Colors.redAccent : null,
                                                    borderRadius: BorderRadius.circular(7.5)
                                                ),
                                                padding: EdgeInsets.all(7.5),
                                                duration: Duration(milliseconds: 300),
                                                child: Text('None',
                                                    style: TextStyle(
                                                      fontWeight: _selectedNormalizationMethod == 0 ? FontWeight.w500 : null,
                                                      color: _selectedNormalizationMethod == 0 ? Colors.white : null
                                                    )),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => setState((){_selectedNormalizationMethod = 1;}),
                                              child: AnimatedContainer(
                                                decoration: BoxDecoration(
                                                    color: _selectedNormalizationMethod == 1 ? Colors.redAccent : null,
                                                    borderRadius: BorderRadius.circular(7.5)
                                                ),
                                                padding: EdgeInsets.all(7.5),
                                                duration: Duration(milliseconds: 300),
                                                child: Text('Min/Max',
                                                    style: TextStyle(
                                                        fontWeight: _selectedNormalizationMethod == 1 ? FontWeight.w500 : null,
                                                        color: _selectedNormalizationMethod == 1 ? Colors.white : null
                                                    )),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => setState((){_selectedNormalizationMethod = 2;}),
                                              child: AnimatedContainer(
                                                decoration: BoxDecoration(
                                                    color: _selectedNormalizationMethod == 2 ? Colors.redAccent : null,
                                                    borderRadius: BorderRadius.circular(7.5)
                                                ),
                                                padding: EdgeInsets.all(7.5),
                                                duration: Duration(milliseconds: 300),
                                                child: Text('Standard',
                                                    style: TextStyle(
                                                        fontWeight: _selectedNormalizationMethod == 2 ? FontWeight.w500 : null,
                                                        color: _selectedNormalizationMethod == 2 ? Colors.white : null
                                                    )),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  (MediaQuery.of(context).orientation == Orientation.portrait) ? ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                            widget.model.type.category == ModelCategory.CLUSTERING ?
                                            "Scoring label":
                                            "Prediction column (Label)",
                                            style: TextStyle(fontWeight: FontWeight.bold),),
                                          SizedBox(width: 5),
                                          GestureDetector(
                                            child: Icon(Icons.help),
                                            onTap: (){
                                              Navigator.push(context, new HeroDialogRoute(
                                                  builder: (BuildContext context) =>
                                                      InformationDialog(
                                                        tag: "train_comm_err",
                                                        text:
                                                        widget.model.type.category == ModelCategory.CLUSTERING ?
                                                        "In clustering, the model doesn't try to learn the output and doesn't care about it\n"
                                                        "The label is only used to score the model. Choose a feature that represents the goal of your model.\n"
                                                        "If your data is labeled, make sure that the values for the label you choose for scoring are [0, 1, ...], up to how many clusters your data contains.\n"
                                                        "If you just want to find patterns in your data set, don't choose anything.":
                                                        widget.model.type.category == ModelCategory.REGRESSION ?

                                                        "The model learns how the label changes in respect to the features in order to predict it.\n"
                                                        "In regression, the output is a value on a continious spectrum. Things like pricing, age, etc...":

                                                        "The model learns how the label changes in respect to the features in order to predict it.\n"
                                                        "In classification, the outputs are discrete values that represent your classes. Things like country, maritial status, etc... Don't use columns with a continiuous spectrum as a label.",
                                                        fontSize: 13.5,
                                                      )
                                              ));
                                            },
                                          )
                                        ],
                                      ),
                                      subtitle: yColumn == null
                                          ? Text(
                                              widget.model.type.category == ModelCategory.CLUSTERING ?
                                              "The column used to score your model":
                                              "The column your model will predict",
                                              style: TextStyle(fontSize: 13))
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Text(
                                                    '${yColumn['name']} (${yColumn['type'] == 'int64' ? 'Integer' : yColumn['type'] == 'float64' ? 'Float' : 'String'})',
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        yColumn = null;
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: <Widget>[
                                                        Icon(Icons.arrow_downward),
                                                        Text(
                                                          "Remove",
                                                          style:
                                                              TextStyle(fontSize: 11),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                      ) : SizedBox(),
                                  ListTile(
                                      title: Row(
                                        children: [
                                          Text("Columns to ignore", style: TextStyle(fontWeight: FontWeight.bold),),
                                          SizedBox(width: 5),
                                          GestureDetector(
                                            child: Icon(Icons.help),
                                            onTap: (){
                                              Navigator.push(context, new HeroDialogRoute(
                                                  builder: (BuildContext context) =>
                                                      InformationDialog(
                                                        tag: "train_comm_err",
                                                        text: "Put any columns that you think are not significant to your output result. Things like customer name and number. "
                                                        "These columns will be dropped before training, so they won't be used in the training process.",
                                                        fontSize: 13.5,
                                                      )
                                              ));
                                            },
                                          )
                                        ],
                                      ),
                                      subtitle: AnimatedSize(
                                        vsync: this,
                                        duration: Duration(milliseconds: 300),
                                        child: toDropColumns.isEmpty
                                            ? Text(
                                                "The columns your model won't use for training",
                                                style: TextStyle(fontSize: 13))
                                            : ConstrainedBox(
                                                constraints:
                                                    BoxConstraints(maxHeight:
                                                    (MediaQuery.of(context).orientation == Orientation.portrait) ? 100 : 70),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children:
                                                        toDropColumns.map((column) {
                                                      return Padding(
                                                        padding: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Text(
                                                                    '${column['name']} (${column['type'] == 'int64' ? 'Integer' : column['type'] == 'float64' ? 'Float' : 'String'})',
                                                                    style: TextStyle(
                                                                        fontSize: 15,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  toDropColumns
                                                                      .remove(column);
                                                                });
                                                              },
                                                              child: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize.min,
                                                                children: <Widget>[
                                                                  Icon(Icons
                                                                      .arrow_downward),
                                                                  Text(
                                                                    "Remove",
                                                                    style: TextStyle(
                                                                        fontSize: 11),
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                )),
                                      )),
                                  (MediaQuery.of(context).orientation == Orientation.portrait) ? ListTile(
                                    title: Row(
                                      children: [
                                        Text("Available columns (Features)", style: TextStyle(fontWeight: FontWeight.bold),),
                                        SizedBox(
                                            width: 5
                                        ),
                                        GestureDetector(
                                          child: Icon(Icons.help),
                                          onTap: (){
                                            Navigator.push(context, new HeroDialogRoute(
                                                builder: (BuildContext context) =>
                                                    InformationDialog(
                                                      tag: "train_comm_err",
                                                      text: "The columns that your model will use when training.",
                                                      fontSize: 13.5,
                                                    )
                                            ));
                                          },
                                        )
                                      ],
                                    ),
                                    subtitle: AnimatedSize(
                                      vsync: this,
                                      duration: Duration(milliseconds: 300),
                                      child: widget.dataSet.columns.where((column)=>(column!=yColumn && !toDropColumns.contains(column))).isEmpty
                                          ? Text(
                                          "You have no columns to train your model with :(",
                                          style: TextStyle(fontSize: 13))
                                          : ConstrainedBox(
                                          constraints:
                                          BoxConstraints(maxHeight: 150),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                              widget.dataSet.columns.where((column)=>(column!=yColumn && !toDropColumns.contains(column))).map((column) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Text(
                                                          '${column['name']} (${column['type'] == 'int64' ? 'Integer' : column['type'] == 'float64' ? 'Float' : 'String'})',
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .black),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            toDropColumns
                                                                .add(column);
                                                          });
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(Icons
                                                                .blur_off),
                                                            Text(
                                                              "Ignore",
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 10,),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            yColumn = column;
                                                          });
                                                        },
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          children: <Widget>[
                                                            Icon(widget.model.type.category != ModelCategory.CLUSTERING ?
                                                                FontAwesomeIcons.brain : FontAwesomeIcons.percent,

                                                            ),
                                                            Text(
                                                              widget.model.type.category != ModelCategory.CLUSTERING ? "Predict" : "Score",
                                                              style: TextStyle(
                                                                  fontSize: 11),
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          )),
                                    )
                                  ) : SizedBox(),
                                ],
                              ),
                            ),
                            (MediaQuery.of(context).orientation == Orientation.landscape) ? Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  ListTile(
                                      title: Row(
                                        children: [
                                          Text(
                                            widget.model.type.category == ModelCategory.CLUSTERING ?
                                            "Scoring label":
                                            "Prediction column (Label)",
                                            style: TextStyle(fontWeight: FontWeight.bold),),
                                          SizedBox(width: 5),
                                          GestureDetector(
                                            child: Icon(Icons.help),
                                            onTap: (){
                                              Navigator.push(context, new HeroDialogRoute(
                                                  builder: (BuildContext context) =>
                                                      InformationDialog(
                                                        tag: "train_comm_err",
                                                        text:
                                                        widget.model.type.category == ModelCategory.CLUSTERING ?
                                                        "In clustering, the model doesn't try to learn the output and doesn't care about it\n"
                                                            "The label is only used to score the model. Choose a feature that represents the goal of your model.\n"
                                                            "If your data is labeled, make sure that the values for the label you choose for scoring are [0, 1, ...], up to how many clusters your data contains.\n"
                                                            "If you just want to find patterns in your data set, choose any column you want to ignore instead, and ignore the scoring of the model.":
                                                        widget.model.type.category == ModelCategory.REGRESSION ?

                                                        "The model learns how the label changes in respect to the features in order to predict it.\n"
                                                            "In regression, the output is a value on a continious spectrum. Things like pricing, age, etc...":

                                                        "The model learns how the label changes in respect to the features in order to predict it.\n"
                                                            "In classification, the outputs are discrete values that represent your classes. Don't use columns with a continiuous spectrum as a label.",
                                                        fontSize: 13.5,
                                                      )
                                              ));
                                            },
                                          )
                                        ],
                                      ),
                                      subtitle: yColumn == null
                                          ? Text(
                                          "The column your model should predict",
                                          style: TextStyle(fontSize: 13))
                                          : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                '${yColumn['name']} (${yColumn['type'] == 'int64' ? 'Integer' : yColumn['type'] == 'float64' ? 'Float' : 'String'})',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  yColumn = null;
                                                });
                                              },
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(Icons.arrow_downward),
                                                  Text(
                                                    "Remove",
                                                    style:
                                                    TextStyle(fontSize: 11),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                  ),
                                  ListTile(
                                      title: Row(
                                        children: [
                                          Text("Available columns (Features)", style: TextStyle(fontWeight: FontWeight.bold),),
                                          SizedBox(
                                              width: 5
                                          ),
                                          GestureDetector(
                                            child: Icon(Icons.help),
                                            onTap: (){
                                              Navigator.push(context, new HeroDialogRoute(
                                                  builder: (BuildContext context) =>
                                                      InformationDialog(
                                                        tag: "train_comm_err",
                                                        text: "The columns that your model will use when training.",
                                                        fontSize: 13.5,
                                                      )
                                              ));
                                            },
                                          )
                                        ],
                                      ),
                                      subtitle: AnimatedSize(
                                        vsync: this,
                                        duration: Duration(milliseconds: 300),
                                        child: widget.dataSet.columns.where((column)=>(column!=yColumn && !toDropColumns.contains(column))).isEmpty
                                            ? Text(
                                            "You have no columns to train your model with :(",
                                            style: TextStyle(fontSize: 13))
                                            : ConstrainedBox(
                                            constraints:
                                            BoxConstraints(maxHeight: 150),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children:
                                                widget.dataSet.columns.where((column)=>(column!=yColumn && !toDropColumns.contains(column))).map((column) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        Expanded(
                                                          child: Text(
                                                            '${column['name']} (${column['type'] == 'int64' ? 'Integer' : column['type'] == 'float64' ? 'Float' : 'String'})',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              toDropColumns
                                                                  .add(column);
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            children: <Widget>[
                                                              Icon(Icons
                                                                  .blur_off),
                                                              Text(
                                                                "Ignore",
                                                                style: TextStyle(
                                                                    fontSize: 11),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 10,),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              yColumn = column;
                                                            });
                                                          },
                                                          child: Column(
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            children: <Widget>[
                                                              Icon(widget.model.type.category != ModelCategory.CLUSTERING ? FontAwesomeIcons.brain : FontAwesomeIcons.percent),
                                                              Text(
                                                                widget.model.type.category != ModelCategory.CLUSTERING ? "Predict" : "Score",
                                                                style: TextStyle(
                                                                    fontSize: 11),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )),
                                      )
                                  ),
                                ],
                              )
                            ) : SizedBox()
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
//                    height: calcBoxHeight(
//                        screenHeight: MediaQuery.of(context).size.height,
//                        context: _key.currentContext,
//                        insetsHeight: MediaQuery.of(context).viewInsets.bottom
//                    )
                        ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        key: _key,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Text("Cancel",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                          ),
                          FlatButton(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 40),
                            color: Colors.redAccent,
                            disabledColor: Colors.grey,
                            onPressed: _trainLoading || (yColumn == null && widget.model.type.category != ModelCategory.CLUSTERING) ||
                                widget.dataSet.columns.where((column)=>(column!=yColumn && !toDropColumns.contains(column))).isEmpty? null :
                                () async {

                              if(_trainLoading)
                                return;
                              setState(() {
                                _trainLoading = true;
                              });
                              try {
                                if(yColumn == null && widget.model.type.category != ModelCategory.CLUSTERING){
                                  Navigator.push(context, HeroDialogRoute(
                                      builder: (BuildContext context) => InformationDialog(
                                        tag: "train_comm_err",
                                        text: "You must choose a prediction column (label)",
                                      )
                                  ));
                                  return;
                                }
                                bool startedTraining = await modelBloc.trainModel(widget.model, widget.dataSet, {
                                  'y_col': yColumn != null ? yColumn['name'] : null,
                                  'to_drop': toDropColumns.map((column)=>column['name']).toList(),
                                  'test_size': _testSize/100.0,
                                  'normalization_method': normalizationMethods[_selectedNormalizationMethod]
                                });
                                print(startedTraining);
                                if(startedTraining)
                                  Navigator.pop(context);
                              } on ServerCommunicationException catch (e) {
                                Navigator.push(context, HeroDialogRoute(
                                  builder: (BuildContext context) => InformationDialog(
                                    tag: "train_comm_err",
                                    text: "Communication with server failed",
                                  )
                                ));
                              } finally {
                                setState(() {
                                  _trainLoading = false;
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Hero(tag: "train_comm_err",
                                child: SizedBox(),),
                                _trainLoading ?
                                SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                ) : SizedBox(),
                                SizedBox(width: 5,),
                                Text("Train",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15)),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
//                layerWidgets[_selectedIndex]
              ],
            ),
          ),
        ),
//                          decoration: BoxDecoration(
//                            borderRadius: BorderRadius.circular(25),
//                            color: Theme.of(context).accentColor
//                          ),
      ),
    );
  }
}
