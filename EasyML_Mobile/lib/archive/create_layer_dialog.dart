
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/models/conv_nn_model.dart';
import 'package:prototyoe_project_app/models/layer_type.dart';
import 'package:prototyoe_project_app/widgets/inputs/double_text_field.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_dropdown.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_textfield.dart';
import 'package:prototyoe_project_app/wrappers.dart';
import 'package:provider/provider.dart';

int _ID = 0;




class CreateLayerDialog extends StatefulWidget {

  MultilayerPerceptronModel model;
  Function onCreate;
  CreateLayerDialog({this.model, this.onCreate});
  @override
  _CreateLayerDialogState createState() => _CreateLayerDialogState();
}

class _CreateLayerDialogState extends State<CreateLayerDialog> {
  ModelBloc modelBloc;

  TextEditingController _filterController = TextEditingController();
  TextEditingController _kernel1Controller = TextEditingController();
  TextEditingController _kernel2Controller = TextEditingController();
  TextEditingController _nodeNumberController = TextEditingController();

  String _selectedActivationFunctionDense;
  String _selectedActivationFunctionConv;
  String _selectedLoss;
  String _SelectedOptimizer;

  List<Widget> layerWidgets = [];
  DropDownSelectionWrapper _activationWrapper = DropDownSelectionWrapper(
    items: <String>['ReLU', 'Tanh', 'Sigmoid', 'Linear']
  );
  List<String> types = ["Dense", "Convolutional", "Dense3", "Dense4"];
  List<GlobalKey> _keys = [GlobalKey(), GlobalKey(), GlobalKey(), GlobalKey()];
  final _key = new GlobalKey();
  // adding layer widgets in method
  // (can't add them directly because they have non-static fields which is not allowed during initialization for some reason

  double calcBoxHeight({double screenHeight, BuildContext context, double insetsHeight}){
    print(screenHeight);
    if(context != null)
      print((context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy);
    print(insetsHeight);
    if(insetsHeight == 0 || context == null)
      return 10;
    double value = insetsHeight-(screenHeight-(context.findRenderObject() as RenderBox).localToGlobal(Offset.zero).dy);
    if(value < 10)
      return 10;

    return value;
  }

  @override
  void initState() {
    super.initState();
//    _ID = widget.model.layers.length;
//    _selectedActivationFunctionDense = _activations[0];
//    _selectedActivationFunctionConv = _activations[0];
//    WidgetsBinding.instance.addPersistentFrameCallback(
//        (_){
//          print("Tested");
//        }
//    );
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    modelBloc = Provider.of<ModelBloc>(context);
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width*0.85,
        child: Material(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Hero(tag: "createlayer", child: SizedBox()),
                Text("Add a Layer", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                Container(
                  height: 50,
                  child: ListView.builder(
                      itemCount: types.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index){
                        return GestureDetector(
                          onTap: (){
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            child: Text(types[index], style: TextStyle(
                                fontSize: 18,
                                fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.w600,
                                color: _selectedIndex == index ? Colors.redAccent : Theme.of(context).primaryColor
                            )
                            ),
                          ),
                        );
                      }
                  ),
                ),
                Builder(
                  builder: (BuildContext context){
                    switch(_selectedIndex){
                      case 0:
                        return Column(
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height*0.5-calcBoxHeight(
                                    screenHeight: MediaQuery.of(context).size.height,
                                    context: _keys[0].currentContext,
                                    insetsHeight: MediaQuery.of(context).viewInsets.bottom
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 15),
                                    ////////////////////////////////////////////////////
                                    HelpTextField(name: "Number of nodes", controller: _nodeNumberController),
                                    SizedBox(height: 10,),
                                    HelpDropDown(
                                      name: "Activation function",
                                      dropDownSelectionWrapper: _activationWrapper,
                                      ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    ExpansionTile(
                                      initiallyExpanded: false,
                                      trailing: Icon(null),
                                      leading: Icon(null),
                                      title: Center(child: Text('advanced options')),
                                      subtitle: Icon(Icons.arrow_drop_down),
                                      children: <Widget>[
                                        LimitedBox(
//                maxHeight: 150,
//                maxWidth: 150,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 10,),
                                              HelpTextField(name: "Kernel Initializer", controller: new TextEditingController()),
                                              SizedBox(height: 10,),
                                              HelpTextField(name: "bias_initializer", controller: new TextEditingController()),
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    ////////////////////////////////////////////////////
                                    SizedBox(height: 10),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: calcBoxHeight(
                                  screenHeight: MediaQuery.of(context).size.height,
                                  context: _keys[0].currentContext,
                                  insetsHeight: MediaQuery.of(context).viewInsets.bottom
                              )
                            ),
                            Row(
                              key: _keys[0],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                  color: Colors.white,
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                ),
                                FlatButton(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                  color: Colors.redAccent,
                                  onPressed:(){
                                    DenseLayer dense = DenseLayer(
                                      numberOfNodes: int.parse(_nodeNumberController.text),
                                      id: _ID++,
                                      imageUrl: "assets/images/brain.png",
                                      type: "Dense",
                                      activationFunction: _selectedActivationFunctionDense,
                                    );

//                                    widget.model.layers.add(dense);

                                    modelBloc.notify();
                                    Navigator.pop(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                )
                              ],
                            )
                          ],
                        );
                      case 1:
                        return Column(
                          children: <Widget>[
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: MediaQuery.of(context).size.height*0.5-calcBoxHeight(
                                    screenHeight: MediaQuery.of(context).size.height,
                                    context: _keys[1].currentContext,
                                    insetsHeight: MediaQuery.of(context).viewInsets.bottom
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(height: 10),
                                    HelpTextField(name: "Number of filters", controller: _filterController),
                                    SizedBox(height: 10),

                                    HelpDropDown(
                                      dropDownSelectionWrapper: _activationWrapper,
                                      name: "Activation function"
                                    ),
                                    SizedBox(height: 10),
                                    DoubleTextField(
                                      ctrl1: _kernel1Controller,
                                      ctrl2: _kernel2Controller,
                                      width: 280,
                                      name: "Kernel size"
                                    ),

                                    SizedBox(
                                      height: 20,
                                    ),
                                    ExpansionTile(
                                      initiallyExpanded: false,
                                      trailing: Icon(null),
                                      title: Padding(
                                        padding: const EdgeInsets.only(left: 80),
                                        child: Text('advanced options'),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(left: 40),
                                        child: Icon(Icons.arrow_drop_down),
                                      ),
                                      children: <Widget>[
                                        LimitedBox(
//                maxWidth: 150,
//                maxHeight: 150,
                                          child: Column(
                                            children: <Widget>[
                                              SizedBox(height: 10,),
                                              HelpTextField(name: "Stride", controller: new TextEditingController()),
                                              SizedBox(height: 10),
                                              HelpTextField(name: "Dilation_rate", controller: new TextEditingController()),
                                              SizedBox(height: 10),
                                              HelpDropDown(
                                                  dropDownSelectionWrapper: _activationWrapper,
                                                  name: "Activation function"
                                              ),
                                              SizedBox(height: 10),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 16),
                                                child: HelpDropDown(
                                                    dropDownSelectionWrapper: _activationWrapper,
                                                    name: "Activation function"
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: calcBoxHeight(
                                  screenHeight: MediaQuery.of(context).size.height,
                                  context: _keys[1].currentContext,
                                  insetsHeight: MediaQuery.of(context).viewInsets.bottom
                              )
                            ),
//                            SizedBox(height: 10,),
                            Row(
                              key: _keys[1],
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: <Widget>[
                                FlatButton(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                  color: Colors.white,
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Cancel", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                ),
                                FlatButton(
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                                  color: Colors.redAccent,
                                  onPressed: (){
                                    ConvolutionalLayer conv = ConvolutionalLayer(
                                      imageUrl: "assets/images/tree.png",
                                      type: "Conv",
                                      filter: int.parse(_filterController.text),
                                      kernel1: int.parse(_kernel1Controller.text),
                                      kernel2: int.parse(_kernel2Controller.text),
                                      activationFunction: _selectedActivationFunctionDense,
                                      id: _ID++,
                                    );

//                                    widget.model.layers.add(conv);

//                                  print(_selectedActivationFunctionConv);
//                                  print("layers.ID is ");
//                                  print(_ID);
//                                  print("layers length is");
//                                  print( widget.model.layers.length);
                                    modelBloc.notify();
                                    Navigator.pop(context);

                                  },
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                                )
                              ],
                            ),
                          ],
                        );
                      default:
                        return Text("Unimplemented index");
                    }
                  },
                )
                ,
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
