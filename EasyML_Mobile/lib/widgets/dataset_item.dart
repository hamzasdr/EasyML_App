import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/pages/dataset_page.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/dialogs/yes_no_dialog.dart';
import 'package:provider/provider.dart';

import 'hero_dialog_route.dart';
import 'inputs/help_textfield.dart';

class DataSetItem extends StatefulWidget {
  DataSet dataSet;
  DataSetItem({this.dataSet});
  @override
  _DataSetItemState createState() => _DataSetItemState();
}

class _DataSetItemState extends State<DataSetItem> {
  TextEditingController _dataSetNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final DataSetBloc dataSetBloc = Provider.of<DataSetBloc>(context);
    return GestureDetector(
      onTap: (){
        // print(widget.model.toJson());
        Navigator.push(context,
            MaterialPageRoute(
                builder: (_)=> DataSetPage(dataSet: widget.dataSet)
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
                            Text(widget.dataSet.name, style: TextStyle(
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
                                                          tag: "deletedatasetdummy",
                                                          child: SizedBox()
                                                      ),
                                                      Text("Enter the new name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                                      SizedBox(height: 10),
                                                      HelpTextField(
                                                        controller: _dataSetNameController,
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
                                                              widget.dataSet.name = _dataSetNameController.text;
                                                              try{
                                                                dataSetBloc.putNetworkDataSet(widget.dataSet);
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                              }
                                                              on ServerCommunicationException catch (e){
                                                                Navigator.pop(context);
                                                                Navigator.push(context, HeroDialogRoute(
                                                                    builder: (BuildContext context) => InformationDialog(
                                                                      tag: "deletedataseterr",
                                                                      text: "Could not connect to server",
                                                                    )
                                                                ));
                                                              }
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
                                FlatButton(
                                  onPressed: (){
                                    Navigator.push(context, HeroDialogRoute(
                                        builder: (BuildContext context) => YesNoDialog(
                                              tag: "deletedatasetdummy",
                                              text: "Are you sure you want to delete this data set?",
                                              subtext: "This action is irreversable!",
                                              action:() async {
                                                try{
                                                  await dataSetBloc.deleteDataSet(widget.dataSet);
                                                  Navigator.pop(context);
                                                }
                                                on ServerCommunicationException catch (e){
                                                  Navigator.push(context, HeroDialogRoute(
                                                    builder: (BuildContext context) => InformationDialog(
                                                      tag: "deletedataseterr",
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
                            Hero(tag: "deletedatasetdummy", child: SizedBox()),
                            Hero(tag: "deletedataseterr", child: SizedBox())

                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100,
                    child: Hero(
                      tag: "dataSet${widget.dataSet.name}${widget.dataSet.id}",
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
                                      image: AssetImage("assets/images/${widget.dataSet.type}.png"),
                                      fit: BoxFit.contain,
                                    ),
                                    clipBehavior: Clip.antiAlias,
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
                    tag: "dataSet${widget.dataSet.name}${widget.dataSet.id}",
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image(
                        image: AssetImage("assets/images/${widget.dataSet.type}.png"),
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
//                  Positioned(
//                    top: 10,
//                    right: 10,
//                    child: widget.model.synced != null && widget.model.synced ?
//                    Icon(Icons.cloud_queue, color: Theme.of(context).primaryColor,) :
//                    widget.model.id != null && widget.model.id >= 0 ?
//                    Icon(Icons.cloud_off, color: Colors.redAccent,):SizedBox(),
//                  )
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
                  Text(widget.dataSet.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.left,),
                  SizedBox(height: 5),
                  Text(DataSet.types[widget.dataSet.type]['name'], style: TextStyle(fontSize: 12), textAlign: TextAlign.left),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
