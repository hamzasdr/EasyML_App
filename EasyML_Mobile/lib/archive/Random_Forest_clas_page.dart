import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/random_forest_classifier_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/dialogs/linear_reg_train_dialog.dart';
import 'package:prototyoe_project_app/widgets/dialogs/yes_no_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/Switch_Field.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_dropdown.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/max_features_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/Upload_data_Field.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../pages/code_page.dart';


List<String> _criterions = <String>['gini', 'entropy'];

class RandomForestClsPage extends StatefulWidget {
  Widget child;
  RandomForestClassifierModel model;
  RandomForestClsPage({this.model});

  @override
  _RandomForestClsPageState createState() => _RandomForestClsPageState();
}

class _RandomForestClsPageState extends State<RandomForestClsPage> with TickerProviderStateMixin {

  BooleanWrapper _bootstrapState = BooleanWrapper(initialValue: true);
  int _n_estimatorsState ;
  int _max_depthState ;
  int _verboseState ;
  double _ccp_alphaState ;
  String  _criterionState ;
//  dynamic _class_weightState;
  dynamic _max_featuresState;

  dynamic _max_featuresvalue;
  String _max_features_def;

  List<DataSet> dataSets;
  DropDownSelectionWrapper _dataSetWrapper;
  bool _cloudLoading = false;
  bool _saveLoading = false;
  Color _backButtonBackgroundColor = Color(0x00000000);
  DataSetBloc dataSetBloc;

  @override
  void initState() {
     _n_estimatorsState = widget.model.nEstimators;
     _max_depthState = widget.model.maxDepth;
     _verboseState = widget.model.verbose;
     _ccp_alphaState = widget.model.ccpAlpha;
      _criterionState = widget.model.criterion;
     _max_featuresState = widget.model.maxFeatures;

     if (_max_featuresState is int){
       _max_featuresvalue = _max_featuresState;
       _max_features_def = 'Integer';
     }
     else if (_max_featuresState is double){
       _max_featuresvalue = _max_featuresState;
       _max_features_def = 'Float';
     }
     else {
       _max_featuresvalue = 0;
       _max_features_def = _max_featuresState;
     }

     _bootstrapState.value = widget.model.bootstrap;
//    httpService = HttpService(model : widget.model);
//    print("my current intercipt is");
//    print(widget.model.fitIntercept);
//    _fitInterceptState = widget.model.fitIntercept;
////    _fitInterceptState = true;
//    _normalizeState = widget.model.normalize;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    if(dataSetBloc == null){
      dataSetBloc = Provider.of<DataSetBloc>(context);
      _dataSetWrapper = DropDownSelectionWrapper(
          items: dataSetBloc.dataSets,
          enableDefaultValue: true
      );
    }
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Scaffold(
//        floatingActionButtonLocation: _BackFloatingActionButtonLocation(),
//        floatingActionButton: FloatingActionButton(
//          child: Icon(Icons.arrow_back),
//          onPressed: () => Navigator.pop(context),
//          backgroundColor: _backButtonBackgroundColor,
//          elevation: 0,
//        ),
        body: Builder(builder: (context){
          return ListView(
            children: <Widget>[
//            CreateModelPage(modelType: widget.modelType),
              Stack(
                children: <Widget>[
                  Hero(
                    tag: "model_comm_err",
                    child: SizedBox(),
                  ),
                  Hero(
                    tag: "${widget.model.name}${widget.model.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                      child: Image(
                        image: AssetImage(widget.model.type.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  Positioned(
//                top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(widget.model.name,
                              style: TextStyle(fontSize: 42, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center),
                          Text(widget.model.type.name,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 5,
                    top: 5,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: userBloc.user == null ? SizedBox() : IconButton(
                      color: widget.model.synced ?
                      Theme.of(context).primaryColor:
                      widget.model.id != null && widget.model.id >= 0 ?
                      Colors.redAccent:
                      Theme.of(context).primaryColor
                      ,
                      icon: Icon(
                          widget.model.synced ?
                          Icons.cloud_done:
                          widget.model.id != null && widget.model.id >= 0 ?
                          Icons.cloud_download :
                          Icons.cloud_upload
                      ),
                      onPressed: _cloudLoading ? null : () async {
                        if(!widget.model.synced){
                          setState(() {
                            _cloudLoading = true;
                          });
                          try {
                            if (widget.model.id == null ||
                                widget.model.id < 0) {
                              await modelBloc.postNetworkModel(widget.model);
                            }
                            else {
                              Model newModel = await modelBloc.getNetworkModel(
                                  widget.model.id);
                              newModel.synced = true;
                              widget.model = await modelBloc.persistModelAt(
                                  newModel,
                                  modelBloc.models.indexOf(widget.model));
                              setState(() {
                                _bootstrapState.value = widget.model.bootstrap;
                                _n_estimatorsState = widget.model.nEstimators;
                                _max_depthState = widget.model.maxDepth;
                                _verboseState = widget.model.verbose;
                                _ccp_alphaState = widget.model.ccpAlpha;
                                _criterionState = widget.model.criterion;
                                _max_featuresState = widget.model.maxFeatures;

                                if (_max_featuresState is int){
                                  _max_featuresvalue = _max_featuresState;
                                  _max_features_def = 'Integer';
                                }
                                else if (_max_featuresState is double){
                                  _max_featuresvalue = _max_featuresState;
                                  _max_features_def = 'Float';
                                }
                                else {
                                  _max_featuresvalue = 0;
                                  _max_features_def = _max_featuresState;
                                }
                              });
                            }
                          } on ServerCommunicationException catch (e) {
                            Navigator.push(context, HeroDialogRoute(
                                builder: (BuildContext context) => InformationDialog(
                                  tag: "model_comm_err",
                                  text: "Could not connect to server",
                                )
                            ));
                          } finally {
                            setState(() {
                              _cloudLoading = false;
                            });
                          }
                        }
                        else{
                          // widget.model.synced = false;
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 15,
                    top: 45,
                    child: widget.model.beingTrained ? Icon(Icons.directions_run) : SizedBox(),
                  ),
                  Positioned(
                    top: 22.5,
                    right: 50,
                    child: _cloudLoading ? SizedBox(
                      width: 12.5,
                      height: 12.5,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        strokeWidth: 2.5,
                      ),
                    ) : SizedBox(),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    left: 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          userBloc.user == null?  "":
                          widget.model.synced ? "":
                          widget.model.id != null && widget.model.id >= 0 ? "The model parameters at the server seems to be different than the locally-stored ones. If you want to keep the parameters from the server, press the cloud download button. If you want to overwrite the server parameters with the local ones, save the model":
                          "Your model is only stored locally. If you want to upload it to enable training, tap the cloud upload button",
                          maxLines: 5,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: widget.model.synced ?
                              Theme.of(context).primaryColor:
                              widget.model.id != null && widget.model.id >= 0 ?
                              Colors.redAccent:
                              Theme.of(context).primaryColor
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  widget.model.type.longDescription,
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
              ),
              widget.child != null ? widget.child : SizedBox(width: 0, height: 0),

              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(left:15),
                    child: Text(
                      'Model Parameters',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 20,),
                  NumField(name:'max depth',value:_max_depthState,type: 0 ,setValue: (int newValue) {
                    setState(() {
                        _max_depthState = newValue;
                        print("current value is ");
                        print(_max_depthState.toString());
                    });}),

                  NumField(name:'n_estimators',value:_n_estimatorsState,type: 0 ,setValue: (int newValue) {
                    setState(() {
                      _n_estimatorsState = newValue;
                    });}),
                  MaxFeaturesField(value: _max_featuresvalue,defval: _max_features_def,setValue: (dynamic newValue) {
                    setState(() {
                      if(newValue is int || newValue is double)
                        _max_featuresvalue = newValue;
                      else _max_features_def = newValue;

                      _max_featuresState = newValue;
                      print(_max_featuresState);
                    });}),
                  SizedBox(height: 10),
                ],
              ),
              SizedBox(height: 15,),
              ExpansionTile(
                initiallyExpanded: false,
                trailing: Icon(null),
                leading: Icon(null),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Advanced Parameters',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
                      textAlign: TextAlign.justify,),
                  ],
                ),
                subtitle: Icon(Icons.keyboard_arrow_down),
                children: <Widget>[
                  Column(
                    children: <Widget>[

                      NumField(name:'verbose',value:_verboseState,type: 0 , setValue: (int newValue) {
                        setState(() {
                          _verboseState = newValue;
                        });}),

                      NumField(name:'ccp_alpha',value:_ccp_alphaState,type: 1 , setValue: (double newValue) {
                        setState(() {
                          newValue = newValue < 0 ? 0 : newValue;
                          _ccp_alphaState = newValue;
                        });}),

                      DynamicField(name:'criterion',values: _criterions ,defval: _criterionState, setValue: (String newValue) {
                        setState(() {
//                          print(newValue);
                          _criterionState = newValue;
                        });}),

                      SwitchField(name:'bootstrap ',booleanWrapper:_bootstrapState, onChanged: (bool newValue) {
                      setState(() {});
                      }
                      ),
//                      SwitchField(name:'oob_score',booleanWrapper:_oob_scoreState, onChanged: (bool newValue) {
//                        setState(() {});
//                      }
//                      ),

//                      SwitchField(name:'warm start',booleanWrapper:_warm_startState, onChanged: (bool newValue) {
//                        setState(() {
//                        });
//                      }
//                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5,),
              /////////////////////////////////////////////////////////////////////////////////////////////////////////
              Row( // Save model and view code
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ButtonTheme(
                        height: 50,
                        child: FlatButton(
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            disabledColor: Colors.grey,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _saveLoading ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator()
                                ) : SizedBox(),
                                widget.model.synced && !_saveLoading ? Icon(Icons.cloud, color: Colors.white,) : SizedBox(),
                                SizedBox(width: widget.model.synced ? 10 : 0),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                      widget.model.beingTrained ? 'The model cannot be modified while it\'s being trained':
                                      _isModified() || (!widget.model.synced && widget.model.id != null && widget.model.id >= 0) ? 'Save model':
                                      'Model saved',
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: widget.model.beingTrained ? 12 : 15)),
                                ),
                              ],
                            ),
                            onPressed: widget.model.beingTrained || _saveLoading ? null :
                            _isModified() || (!widget.model.synced && widget.model.id != null && widget.model.id >= 0) ? () async {
//                        print('save');
//                        print(widget.model.id);
                              setState(() {
                                _saveLoading = true;
                              });
                              widget.model.bootstrap = _bootstrapState.value;
                              widget.model.maxFeatures = _max_featuresState;
                              widget.model.criterion = _criterionState;
                              widget.model.ccpAlpha = _ccp_alphaState;
                              widget.model.verbose = _verboseState;
                              widget.model.maxDepth = _max_depthState;
                              widget.model.nEstimators = _n_estimatorsState;
//                        print(widget.model.toJson());
                              // HttpService.postModel(widget.model,userBloc);

                              try {
                                await modelBloc.putNetworkModel(widget.model);
                                await modelBloc.persistExistingModel(widget.model);
                              } on ServerCommunicationException catch (e) {
                                Navigator.push(context, HeroDialogRoute(
                                    builder: (BuildContext context) => YesNoDialog(
                                      tag: "model_comm_err",
                                      text: "Could not connect to server",
                                      subtext: "Do you want to save the model locally? This will make the model information different that the information at the server",
                                      action: () async {
                                        widget.model.synced = false;
                                        await modelBloc.persistExistingModel(widget.model);
                                        Navigator.pop(context);
                                      },
                                    )
                                ));
                              } finally {
                                setState(() {
                                  _saveLoading = false;
                                });
                              }
                            } : null
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ButtonTheme(
                        height: 50,
                        child: FlatButton(
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            disabledColor: Colors.grey,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.code, color: Colors.white,),
                                SizedBox(width:10),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    _isModified() || (!widget.model.synced && widget.model.id != null && widget.model.id >= 0) ? 'Save model to view code':
                                    'View Python code',
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,),),
                                ),
                              ],
                            ),
                            onPressed:
                            _isModified() ? null : () async {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => CodePage(model: widget.model)
                              ));
                            }
                        ),
                      ),
                    ),
                  ),
                ],
              ),


              SizedBox(height: 5,),
              /////////////////////////////////////////////////////////////////////////////////////////////////////////
              (widget.model.synced && widget.model.id != null && widget.model.id >= 0 ) ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left:15),
                    child: Text(
                      'Input Data',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 15,),

                  HelpDropDown(
                    dropDownSelectionWrapper: _dataSetWrapper,
                    width: MediaQuery.of(context).size.width*0.90,
                    name: "Select data set",
                    onChanged: (name) async {
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20,),

                ],
              ) : SizedBox(),
              (widget.model.synced && widget.model.id != null && widget.model.id >= 0 ) ? Padding(
                  padding: const EdgeInsets.all(8),
                  child: ButtonTheme(
                      height: 50,
                      child: FlatButton(
                          disabledColor: Colors.grey,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Text(
                            (!widget.model.synced && widget.model.id != null && widget.model.id >= 0) || _isModified() ?
                            'Save model to start training': widget.model.beingTrained ?
                            'Training' :
                            'Train Model',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
                          onPressed: (){
                            print(_dataSetWrapper.selectedItem);
                            return _dataSetWrapper.selectedIndex < 0 || _isModified() || widget.model.beingTrained;
                          }() ? null : () async {
                            Navigator.push(context, HeroDialogRoute(
                                builder: (BuildContext context){
                                  return TrainDialog(
                                    model: widget.model,
                                    dataSet: _dataSetWrapper.selectedItem,
                                    // columns: columns,
                                  );
                                })
                            );
                          }
                      )
                  )
              ) : SizedBox(),
              Hero(tag: "randomforest_cls", child: SizedBox())
              ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            ],
          );

        },)
    );
  }

  bool _isModified(){


//    return widget.model.fitIntercept != _fitInterceptState || widget.model.normalize != _normalizeState;
    return widget.model.nEstimators != _n_estimatorsState ||
           widget.model.maxDepth != _max_depthState ||
           widget.model.verbose != _verboseState ||
           widget.model.ccpAlpha != _ccp_alphaState ||
           widget.model.criterion != _criterionState ||
           widget.model.maxFeatures != _max_featuresState ||
           widget.model.bootstrap != _bootstrapState.value ;

  }
}

class _BackFloatingActionButtonLocation extends FloatingActionButtonLocation{
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(0, 25);
  }

}