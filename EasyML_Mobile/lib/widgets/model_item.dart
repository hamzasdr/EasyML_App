import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/pages/model_page.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/dialogs/yes_no_dialog.dart';
import 'package:provider/provider.dart';
import 'hero_dialog_route.dart';
import 'inputs/help_textfield.dart';

class ModelItem extends StatefulWidget {
  Model model;
  ModelItem({this.model});
  @override
  _ModelItemState createState() => _ModelItemState();
}

class _ModelItemState extends State<ModelItem> {
  TextEditingController _modelNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return GestureDetector(
      onTap: (){
        print("Tapped ${widget.model.name}");
        // print(widget.model.toJson());
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_)=> ModelPage(model: widget.model)
            ));
      },

      onLongPress: (){
        Navigator.push(context, new HeroDialogRoute(
            builder: (BuildContext context){
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[

                  Positioned(
                    top: 170,
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.75,
                      child: Material(
                        textStyle: TextStyle(fontSize: 16, color: Colors.black),
                        borderRadius: BorderRadius.circular(25),
                        color: Theme.of(context).accentColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 50),
                            Text(widget.model.name, style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                              textAlign: TextAlign.center,),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, HeroDialogRoute(
                                        builder: (BuildContext context){
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
                                                      Hero(
                                                          tag: "deletemodeldummy",
                                                          child: SizedBox()
                                                      ),
                                                      Text("Enter the new name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                                      SizedBox(height: 10),
                                                      HelpTextField(
                                                        controller: _modelNameController,
                                                        inputType: TextInputType.text,
                                                        enableHelp: false,
                                                        width: (MediaQuery.of(context).size.width*0.85)-50,
                                                        name: "Model name",
                                                      ),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          FlatButton(
                                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                            color: Colors.redAccent,
                                                            onPressed: () async {
                                                              Model existingModel;
                                                              for(Model mdl in modelBloc.models)
                                                                if (mdl.name == _modelNameController.text){
                                                                  existingModel = mdl;
                                                                  break;
                                                                }
                                                              if(existingModel == null){
                                                                widget.model.name = _modelNameController.text;
                                                                if(widget.model.id != null && widget.model.id >= 0)
                                                                  try{
                                                                    await modelBloc.putNetworkModel(widget.model);
                                                                  }
                                                                  on ServerCommunicationException catch (e){
                                                                    Navigator.pop(context);
                                                                    Navigator.push(context, new HeroDialogRoute(
                                                                        builder: (BuildContext context) => InformationDialog(
                                                                          tag: "deletemodelerr",
                                                                          text: "Could not connect to server",
                                                                        )
                                                                    ));
                                                                  }
                                                                await modelBloc.persistExistingModel(widget.model);
                                                                _modelNameController.clear();
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                return;
                                                              }
                                                              Navigator.pop(context);
                                                              Navigator.push(context, new HeroDialogRoute(
                                                                  builder: (BuildContext context) => InformationDialog(
                                                                    tag: "deletemodelerr",
                                                                    text: "A model with the same name already exists",
                                                                  )
                                                              ));
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),

                                                          )
                                                        ],
                                                      )
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
                                        }));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.edit),
                                      Text("Edit name", style: TextStyle(fontSize: 12),)
                                    ],
                                  ),
                                ),
//                                FlatButton(
//                                  onPressed: (){},
//                                  child: Column(
//                                    children: <Widget>[
//                                      Icon(Icons.content_copy),
//                                      Text("Duplicate", style: TextStyle(fontSize: 12),)
//                                    ],
//                                  ),
//                                ),
                                FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, HeroDialogRoute(
                                        builder: (BuildContext context) => YesNoDialog(
                                            tag: "deletemodeldummy",
                                            text: "Are you sure you want to delete this model?",
                                            subtext: "This action is irreversable",
                                            action: () async {
                                              try {
                                                await modelBloc.deleteModel(widget.model);
                                                Navigator.pop(context);
                                              } on ServerCommunicationException catch (e) {
                                                Navigator.pop(context);
                                                Navigator.push(context, new HeroDialogRoute(
                                                  builder: (BuildContext context) => InformationDialog(
                                                    tag: "deletemodelerr",
                                                    text: "Could not connect to server",
                                                  )
                                                ));
                                              }
                                              Navigator.pop(context);
                                            },
                                          )

                                    ));
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Icon(Icons.delete),
                                      Text("Delete", style: TextStyle(fontSize: 12),)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Hero(tag: "deletemodeldummy", child: SizedBox()),
                            Hero(tag: "deletemodelerr", child: SizedBox()),

                          ],
                        ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 100,
                    child: Hero(
                      tag: "model${widget.model.name}${widget.model.id}",
                      child: Container(
                        width: 120,
                        height: 120,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Column(
                            children: <Widget>[
                              Stack(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(120),
                                    child: Image(
                                      image: AssetImage(widget.model.type.imageUrl),
                                      fit: BoxFit.contain,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                  ),
                                  Positioned(
                                    bottom: 25,
                                    left: 0,
                                    right: 0,
                                    child: SizedBox(
                                        width: 75,
                                        height: 75,
                                        child:
                                        widget.model.type.category == ModelCategory.REGRESSION ?
                                        Image.asset('assets/images/regression.png'):
                                        widget.model.type.category == ModelCategory.CLASSIFICATION ?
                                        Image.asset('assets/images/classification.png'):
                                        Image.asset('assets/images/clustering.png')
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    right: 60,
                    child: GestureDetector(
                        child: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
                        onTap: ()=>Navigator.pop(context)
                    ),
                  )
                ],
              );
            }
        ));
      },

      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
//              color: Colors.white
              ),
              child: Stack(
                children: <Widget>[
                  Hero(
                    tag: "model${widget.model.name}${widget.model.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image(
                        image: AssetImage(widget.model.type.imageUrl),
                        fit: BoxFit.contain,

                      ),
                      clipBehavior: Clip.antiAlias,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(15),
//                    child: Column(
//                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                      crossAxisAlignment: CrossAxisAlignment.center,
//                      children: <Widget>[
//                        Text(widget.modelType.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
//                        Text(widget.modelType.shortDescription, textAlign: TextAlign.center)
//                      ],
//                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: widget.model.synced != null && widget.model.synced ?
                    Icon(Icons.cloud_queue, color: Theme.of(context).primaryColor,) :
                    widget.model.id != null && widget.model.id >= 0 ?
                    Icon(Icons.cloud_off, color: Colors.redAccent,):SizedBox(),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
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
                  Positioned(
                    top: 40,
                    right: 10,
                    child: widget.model.beingTrained ? Icon(Icons.directions_run) : SizedBox(),
                  ),
                ],
              ),
            ),
            Container(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(widget.model.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.left,),
                  SizedBox(height: 5),
                  Text(widget.model.type.name, style: TextStyle(fontSize: 12), textAlign: TextAlign.left),
                  Text(widget.model.type.categoryName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300), textAlign: TextAlign.left),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
