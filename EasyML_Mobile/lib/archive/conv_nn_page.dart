
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/widgets/dialogs/linear_reg_train_dialog.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/network/http_service.dart';
import 'package:prototyoe_project_app/widgets/carousels/layer_carousel.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_dropdown.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_textfield.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import 'package:provider/provider.dart';
import 'package:prototyoe_project_app/widgets/inputs/num_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/dynamic_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_addmulti_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

double length;

class ConvNNPage extends StatefulWidget {
  Widget child;
  MultilayerPerceptronModel model;
  ConvNNPage({this.child, this.model});

  @override
  _ConvNNPageState createState() => _ConvNNPageState();
}

class _ConvNNPageState extends State<ConvNNPage> with SingleTickerProviderStateMixin {

  List<String> _activations = <String>['identity', 'logistic', 'tanh', 'relu'];
  List<String> _learning_rates = <String>['constant', 'invscaling', 'adaptive'];
  List<String> _Solvers = <String>['lbfgs', 'sgd', 'adam'];


//  DropDownSelectionWrapper _lossWrapper = DropDownSelectionWrapper(items: _Losses);
//  DropDownSelectionWrapper _optimiserWrapper = DropDownSelectionWrapper(items: _Optimisers);
//  TextEditingController _epochsController = TextEditingController();
//  TextEditingController _batchController = TextEditingController();

int _max_iterState;
List <int> _hiddlayersState;
TextEditingController _LayersController = TextEditingController();
String _activationState;
String _solverState;
String _learning_rateState;
double _learning_rate_initState;
double _tolState;

bool temp = true;

AnimationController controller;
Widget _icon = Icon(Icons.refresh);
bool _state = false;


  List<DataSet> dataSets;
  DropDownSelectionWrapper _dataSetWrapper;
  bool _cloudLoading = false;
  bool _saveLoading = false;
  Color _backButtonBackgroundColor = Color(0x00000000);
  DataSetBloc dataSetBloc;

  @override
  void initState() {
//    print("init");
     _max_iterState = widget.model.maxIter;
    _activationState = widget.model.activation;
    _solverState = widget.model.solver;
    _learning_rateState = widget.model.learningRate;
    _learning_rate_initState = widget.model.learningRateInit;
    _tolState = widget.model.tol;

    _hiddlayersState = [];
    for (int i = 0 ; i < widget.model.hiddenLayerSizes.length; i++) {
      _hiddlayersState.add(widget.model.hiddenLayerSizes[i]);
    }
    print(widget.model.maxIter.toString());
    print(widget.model.hiddenLayerSizes.length);
//    httpService = HttpService(model : widget.model);
//    controller = AnimationController(duration: Duration(milliseconds: 500),vsync: this);
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
                  top: 350,
                  right: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50, right: 50),
                    child: GestureDetector(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.code,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                       setState(() {
                         print("changing");
                         _max_iterState = 344;
                         _activationState = 'tanh';
                       });
                      },
                    ),
                  ),
                ),

  //TODO: this is the play/pause/sync button
//                GestureDetector(
//                  onTap: (){
//                    if(!_state){
//                      setState(() {
//                        _icon = AnimatedIcon(icon: AnimatedIcons.play_pause,progress: controller,);
//                        _state = true;
//                      });
//                    }
//                    else{
//                      if(controller.value == 1){
//                     controller.reverse();
//                   }
//                   else{
//                     controller.forward();
//                   }
//                    }
//                  },
//                  child: Padding(
//                    padding: const EdgeInsets.only(top: 100, right: 50),
//                    child: Container(
//                      child: _icon,
//                    ),
//                  ),
//                ),

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
                              _max_iterState = widget.model.maxIter;
//                              _hiddlayersState = widget.model.hidden_layers;
                              _activationState = widget.model.activation;
                              _solverState = widget.model.solver;
                              _learning_rateState = widget.model.learningRate;
                              _learning_rate_initState = widget.model.learningRateInit;
                              _tolState = widget.model.tol;
                              _hiddlayersState = widget.model.hiddenLayerSizes.map((_)=>_).toList();
//                              for (int i = 0 ; i < widget.model.hidden_layers.length; i++) {
//                                _hiddlayersState.add(widget.model.hidden_layers[i]);
//                              }
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
                NumField(name:'max Iterations',value:_max_iterState,type: 0 ,setValue: (int newValue) {
                  setState(() {
                    _max_iterState = newValue;
                    print("current value is ");
                    print(_max_iterState.toString());
                  });}),

                AddMultiFields(name: "Add Hidden Layer",controller:_LayersController,onAdd: (int value){
                  _hiddlayersState.add(value);
                  setState(() {

                  });
                    print("current length");
                    print(_hiddlayersState.length);
                    print("model length");
                    print(widget.model.hiddenLayerSizes.length);
                },),
                LayersCarousel(model: widget.model,),
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
                    DynamicField(name:'Activation',values: _activations ,defval: _activationState, setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        _activationState = newValue;
                      });}),

                    DynamicField(name:'Solvers',values: _Solvers ,defval: _solverState, setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        _solverState = newValue;
                      });}),

                    DynamicField(name:'Learning Rate',values: _learning_rates ,defval: _learning_rateState, setValue: (String newValue) {
                      setState(() {
//                          print(newValue);
                        _learning_rateState = newValue;
                      });}),

                    NumField(name:'Intial Learning Rate',value:_learning_rate_initState,type: 1 ,setValue: (double newValue) {
                      setState(() {
                        _learning_rate_initState = newValue;
                        print("current value is ");
                        print(_learning_rate_initState.toString());
                      });}),

                    NumField(name:'Tolerance',value:_tolState,type: 1 ,setValue: (double newValue) {
                      setState(() {
                        _tolState = newValue;
                        print("current value is ");
                        print(_tolState.toString());
                      });}),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 50,),
          /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
                            print("save");
                            widget.model.maxIter = _max_iterState;
                            widget.model.activation = _activationState;
                            widget.model.solver = _solverState;
                            widget.model.learningRate = _learning_rateState;
                            widget.model.learningRateInit = _learning_rate_initState;
                            widget.model.tol = _tolState;
                            widget.model.hiddenLayerSizes = _hiddlayersState.map((_)=>_).toList();

//                            for (int i =  0; i < _hiddlayersState.length; i++) {
//                              widget.model.hidden_layers.add(_hiddlayersState[i]);
//                            }
//                      print("value save is ");
//                      print(widget.model.hidden_layers.length);
//                      print(widget.model.batch_size);
//                      print(widget.model.Loss);
//                      print(widget.model.Optimizer);
//                        print(widget.model.toJson());
                            // HttpService.postModel(widget.model,userBloc);
                            try {
                              await modelBloc.putNetworkModel(widget.model);
                              await modelBloc.persistExistingModel(widget.model);
                              print(widget.model.toJson());
                            } on ServerCommunicationException catch (e) {
                              // TODO: Push a Yes/No dialog that will ask the user to proceed with saving model locally or not
                              Navigator.push(context, HeroDialogRoute(
                                  builder: (BuildContext context) => InformationDialog(
                                    tag: "model_comm_err",
                                    text: "Could not connect to server",
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
//                            Navigator.push(context, MaterialPageRoute(
//                                builder: (context) => CodePage(model: widget.model)
//                            ));
                          }
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 5,),
            /////////////////////////////////////////////////////////////////////////////////////////////////////////
            // TODO: separate this into its own widget
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
            Hero(tag: "neural", child: SizedBox())

            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

          ],
        );

      },)
    );
  }

  bool _isModified(){
//List<int> test1 = [23,23,121,2];
//List<int> test2 = [];
//
//for (int i = 0; i < test1.length; i++) {
//  test2.add(test1[i]);
//}

//test2.add(334);
//print("modified");
//    print(widget.model.id);
    if(_hiddlayersState.length != widget.model.hiddenLayerSizes.length)
      return true;

    bool listsEqual = false;
    for(int i = 0; i < _hiddlayersState.length; i++)
      if(_hiddlayersState[i] != widget.model.hiddenLayerSizes[i]){
        listsEqual = true;
        break;
      }
//    print("is modified called");
//    if(_epochsController.text.isEmpty || _batchController.text.isEmpty)
//      return false;
    return widget.model.maxIter !=  _max_iterState ||
           listsEqual ||
           widget.model.activation != _activationState||
           widget.model.solver != _solverState||
           widget.model.learningRate != _learning_rateState||
           widget.model.learningRateInit != _learning_rate_initState||
           widget.model.tol != _tolState;
//           widget.model.Loss != _lossWrapper.selectedItem;

  }
}

class _BackFloatingActionButtonLocation extends FloatingActionButtonLocation{
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(0, 25);
  }

}