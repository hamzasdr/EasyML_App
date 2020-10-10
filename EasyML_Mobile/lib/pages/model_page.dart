import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/pages/trained_model_page.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/widgets/dialogs/linear_reg_train_dialog.dart';
import 'package:prototyoe_project_app/widgets/dialogs/yes_no_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_dropdown.dart';
import 'package:prototyoe_project_app/widgets/model_params/parameter_stateful_widget.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import 'package:provider/provider.dart';

import 'code_page.dart';

class ModelPage extends StatefulWidget {
  ParameterStatefulWidget modelParams;
  Model model;
  ModelPage({this.model, this.modelParams});

  @override
  _ModelPageState createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> with TickerProviderStateMixin {

  List<DataSet> dataSets;
  DropDownSelectionWrapper _dataSetWrapper;
  bool _cloudLoading = false;
  bool _saveLoading = false;
  Color _backButtonBackgroundColor = Color(0x00000000);
  DataSetBloc dataSetBloc;
  GlobalKey _key = GlobalKey();

  Model _model; // a dummy model that saves state only
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    if(_model == null)
      _model = Model.fromJson(widget.model.toJson());
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
          return RefreshIndicator(
            onRefresh: () async {
              try{
                Model networkModel = await modelBloc.getNetworkModel(widget.model.id);
                await modelBloc.addNetworkModel(networkModel);
                await modelBloc.getModelInformation(widget.model);
              } on SocketException catch (e){}
            },
            color: Theme.of(context).primaryColor,
            child: ListView(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: "model_comm_err",
                      child: SizedBox(),
                    ),
                    Hero(
                      tag: "model${widget.model.name}${widget.model.id}",
                      child: Container(
                        width: MediaQuery.of(context).orientation == Orientation.portrait ? MediaQuery.of(context).size.width : 200,
                        child: Padding(
                          padding: EdgeInsets.all((MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft:  Radius.circular((MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : 30),
                                topRight: Radius.circular((MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : 30),
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                            child: AspectRatio(
                              aspectRatio: MediaQuery.of(context).orientation == Orientation.portrait ? 1 : 1,
                              child: Image(
                                image: AssetImage(widget.model.type.imageUrl),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                      ),

                      /*
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),

                        child: Align(
                          heightFactor: 0.8,
                          widthFactor: 0.8,
                          alignment: Alignment.center,
                          child: Image(
                            image: AssetImage(modelTypeBloc.modelTypes[index].imageUrl),
                            fit: BoxFit.contain,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                      ),
                      */

                    ),

                    Positioned(
                      top: (MediaQuery.of(context).orientation == Orientation.portrait) ? null : 40,
                      bottom: (MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : null,
                      left: (MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : 190,
                      right: (MediaQuery.of(context).orientation == Orientation.portrait) ? 0 : 30,
                      child: Padding(
                        padding: EdgeInsets.all((MediaQuery.of(context).orientation == Orientation.portrait) ? 20 : 0),
                        child: Column(
                          crossAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(widget.model.name,
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                                textAlign: (MediaQuery.of(context).orientation == Orientation.portrait) ? TextAlign.center : TextAlign.left),
                            Text(widget.model.type.name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                textAlign: (MediaQuery.of(context).orientation == Orientation.portrait) ? TextAlign.center : TextAlign.left),
                            Row(
                              mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait) ?
                              MainAxisAlignment.center: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child:
                                      widget.model.type.category == ModelCategory.REGRESSION ?
                                      Image.asset('assets/images/regression.png'):
                                      widget.model.type.category == ModelCategory.CLASSIFICATION ?
                                      Image.asset('assets/images/classification.png'):
                                      Image.asset('assets/images/clustering.png')
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Text(widget.model.type.categoryName,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                                    textAlign: (MediaQuery.of(context).orientation == Orientation.portrait) ? TextAlign.center : TextAlign.left),
                              ],
                            ),
                            SizedBox(height: (MediaQuery.of(context).orientation == Orientation.landscape) ? 10 : 0,),
                            (MediaQuery.of(context).orientation == Orientation.landscape) ? Text(
                              userBloc.user == null?  "":
                              widget.model.synced ? "":
                              widget.model.id != null && widget.model.id >= 0 ? "The model parameters at the server seems to be different than the locally-stored ones. If you want to keep the parameters from the server, press the cloud download button. If you want to overwrite the server parameters with the local ones, save the model":
                              "Your model is only stored locally. If you want to upload it to enable training, tap the cloud upload button",
                              maxLines: 5,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: widget.model.synced ?
                                  Theme.of(context).primaryColor:
                                  widget.model.id != null && widget.model.id >= 0 ?
                                  Colors.redAccent:
                                  Theme.of(context).primaryColor
                              ),
                            ) : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: (MediaQuery.of(context).orientation == Orientation.portrait) ? 5 : 20,
                      top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 5 : 20,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      right: (MediaQuery.of(context).orientation == Orientation.portrait) ? 5 : 20,
                      top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 5 : 20,
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
                                setState(() {
                                  _model = Model.fromJson(widget.model.toJson());
                                });
                                (_key.currentWidget as ParameterStatefulWidget).stateModel = _model;
                                (_key.currentState as ParameterState).update();
                              }
                              else {
                                Model newModel = await modelBloc.getNetworkModel(
                                    widget.model.id);
                                newModel.synced = true;
                                widget.model = await modelBloc.persistModelAt(
                                    newModel,
                                    modelBloc.models.indexOf(widget.model));



//                              Navigator.pop(context);
//                              Navigator.push(context,
//                                  MaterialPageRoute(
//                                      builder: (_)=> widget.model.type.createPage(model: widget.model)
//                                  ));

                                setState(() {
                                  _model = Model.fromJson(widget.model.toJson());
                                });
                                (_key.currentWidget as ParameterStatefulWidget).stateModel = _model;
                                (_key.currentState as ParameterState).update();
//                              setState(() {
//
//                              });

//                              setState(() {
//                                _n_neighborsState = widget.model.nNeighbors;
//                                _algorithmState = widget.model.algorithm;
//                                _weightState = widget.model.weights;
//                              });
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
                      right: (MediaQuery.of(context).orientation == Orientation.portrait) ? 15 : 35,
                      top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 45 : 65,
                      child: widget.model.beingTrained ? Icon(Icons.directions_run) : SizedBox(),
                    ),
                    Positioned(
                      top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 22.5 : 37.5,
                      right: (MediaQuery.of(context).orientation == Orientation.portrait) ? 50 : 65,
                      child: _cloudLoading ? SizedBox(
                        width:  12.5,
                        height: 12.5,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                          strokeWidth: 2.5,
                        ),
                      ) : SizedBox(),
                    ),
                    (MediaQuery.of(context).orientation == Orientation.portrait) ? Positioned(
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
                                fontWeight: FontWeight.w600,
                                color: widget.model.synced ?
                                Theme.of(context).primaryColor:
                                widget.model.id != null && widget.model.id >= 0 ?
                                Colors.redAccent:
                                Theme.of(context).primaryColor
                            ),
                          ),
                        ],
                      ),
                    ) : SizedBox()
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: ExpansionTile(
                    title: Text('View model description'),
                    children: [
                      Text(
                        widget.model.type.longDescription,
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

                // SizedBox(height: 20),
                ParameterStatefulWidget.fromModel(
                  stateModel: _model,
                  onChanged: ()=>setState((){}),
                  key: _key
                ),
                SizedBox(height: 5,),
                /////////////////////////////////////////////////////////////////////////////////////////////////////////
//              Row(
//                mainAxisAlignment: MainAxisAlignment.start,
//                children: [
//                  Transform(
//                    transform: Matrix4.diagonal3Values(14, 1, 1),
//                    child: CupertinoSwitch(value: true, onChanged: (v){},),
//                  ),
//                ],
//              ),
                Row( // Save model and view code
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                            color: widget.model.beingTrained || _saveLoading ||
                              !(_isModified() || (!widget.model.synced && widget.model.id != null && widget.model.id >= 0))?
                            Colors.grey : Colors.red,
                            borderRadius: BorderRadius.circular(15)
                          ),
                          child: ButtonTheme(
                            height: 50,
                            child: FlatButton(
                                // color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                // disabledColor: Colors.grey,
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
                                          widget.model.beingTrained ? 'Can\'t save while training':
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
                                  _model.id = widget.model.id;
                                  _model.synced = widget.model.synced;
                                  _model.beingTrained = widget.model.beingTrained;
                                  _model.type = widget.model.type;
                                  _model.name = widget.model.name;

//                              widget.model.weights = _weightState;
//                              widget.model.algorithm = _algorithmState;
//                              widget.model.nNeighbors = _n_neighborsState;
//                        print(widget.model.toJson());
                                  // HttpService.postModel(widget.model,userBloc);

                                  try {
                                    await modelBloc.putNetworkModel(_model);
                                    widget.model = await modelBloc.persistModelAt(_model, modelBloc.models.indexOf(widget.model));
                                    _model = Model.fromJson(widget.model.toJson());
                                  } on ServerCommunicationException catch (e) {
                                    Navigator.push(context, HeroDialogRoute(
                                        builder: (BuildContext context) => YesNoDialog(
                                          tag: "model_comm_err",
                                          text: "Could not connect to server",
                                          subtext: "Do you want to save the model locally? This will make the model information different that the information at the server",
                                          action: () async {
                                            widget.model.synced = false;
                                            widget.model = await modelBloc.persistExistingModel(widget.model);
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
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          decoration: BoxDecoration(
                              color: _isModified() ?
                              Colors.grey : Colors.green,
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: ButtonTheme(
                            height: 50,
                            child: FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(FontAwesomeIcons.code, color: Colors.white,),
                                    SizedBox(width:10),
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        _isModified() ? 'Save model to view code':
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
                        'Training',
                        style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    SizedBox(height: 15,),

                    HelpDropDown(
                      dropDownSelectionWrapper: _dataSetWrapper,
                      width: MediaQuery.of(context).size.width* 1-76,
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
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                  color: (_dataSetWrapper.selectedIndex < 0 || _isModified() || widget.model.beingTrained)?
                                  Colors.grey : Colors.blue,
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: ButtonTheme(
                                  height: 50,
                                  child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Text(
                                        (!widget.model.synced && widget.model.id != null && widget.model.id >= 0) || _isModified() ?
                                        'Save model to start training': widget.model.beingTrained ?
                                        'Training' :
                                        'Train Model',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                                        textAlign: TextAlign.center,
                                      ),
                                      onPressed: _dataSetWrapper.selectedIndex < 0 || _isModified() || widget.model.beingTrained ? null : () async {
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
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              decoration: BoxDecoration(
                                  color: (widget.model.info == null ||  widget.model.info.keys.isEmpty)?
                                  Colors.grey : Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              child: ButtonTheme(
                                  height: 50,
                                  child: FlatButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15)
                                      ),
                                      child: Text(
                                          (widget.model.info == null ||  widget.model.info.keys.isEmpty) ?
                                          'Train the model to view the trained model information' :
                                          'View trained model information',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600,
                                            fontSize: (widget.model.info == null ||  widget.model.info.keys.isEmpty) ? 10 : 15),
                                        textAlign: TextAlign.center,
                                      ),

                                      onPressed: (widget.model.info == null || widget.model.info.keys.isEmpty) ? null : () async {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (BuildContext context) => TrainedModelPage(model: widget.model,)
                                        )
                                        );
                                      }
                                  )
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ) : SizedBox(),
                Hero(tag: widget.model.type.name, child: SizedBox())
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

              ],
            ),
          );

        },)
    );
  }

  bool _isModified(){
//    print("_model: ${_model.toJson()}");
//    print(" model: ${widget.model.toJson()}");
    bool _isModified = !_model.equals(widget.model);
//    print("isModified: $_isModified");
    return _isModified;
  }
}

class _BackFloatingActionButtonLocation extends FloatingActionButtonLocation{
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    return Offset(0, 25);
  }

}