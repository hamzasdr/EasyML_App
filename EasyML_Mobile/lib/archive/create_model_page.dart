import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:provider/provider.dart';

//Model _typevalue(String type,String name,ModelType modeltype,String image_url){
//    Model model;
//    model.runtimeType;
//    switch(type){
//      case "Deep Neural Network" :
//        model = ConventionalNeuralNetworkModel(
//          id: 0,
//          imageUrl: image_url,
//          name: name,
//          type: modeltype,
//        );
//        break;
//      case "K nearest neighbour" :
//        {
//          model = ConventionalNeuralNetworkModel(
//            id: 0,
//            imageUrl: image_url,
//            name: name,
//            type: modeltype,
//          );
//          break;
//        }
//      case "Decision Tree" :
//        {
//          model = ConventionalNeuralNetworkModel(
//            id: 0,
//            imageUrl: image_url,
//            name: name,
//            type: modeltype,
//          );
//          break;
//        }
//      case "Random Forest" :
//        {
//          model = ConventionalNeuralNetworkModel(
//            id: 0,
//            imageUrl: image_url,
//            name: name,
//            type: modeltype,
//          );
//          break;
//        }
//      case "Linear Regression" :
//        {
//          model = LinearReg(
//            id: 0,
//            imageUrl: image_url,
//            name: name,
//            type: modeltype,
//          );
//          break;
//        }
//      default: print("Doesnt Exist");
//    }
//    return model;
//}
//
//void route_model(Model model,BuildContext context){
//    String model_name = model.type.name;
//    switch(model_name){
//      case "Deep Neural Network" :
//        Navigator.push(context,
//            MaterialPageRoute(
//                builder: (_)=> ConvNNPage(model: model)
//            ));
//        break;
//      case "K nearest neighbour" :
//        {
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (_)=> ConvNNPage(model: model)
//              ));
//          break;
//        }
//      case "Decision Tree" :
//        {
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (_)=> ConvNNPage(model: model)
//              ));
//          break;
//        }
//      case "Random Forest" :
//        {
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (_)=> ConvNNPage(model: model)
//              ));
//          break;
//        }
//      case "Linear Regression" :
//        {
//          print("in Lienaer Case going to Conv page");
//          Navigator.push(context,
//              MaterialPageRoute(
//                  builder: (_)=> LinearReg_page(model: model)
//              ));
//          break;
//        }
//      default: print("Doesnt Exist");
//    }
//}


class CreateModelPage extends StatefulWidget {
  Widget child;
  ModelType modelType;
  CreateModelPage({this.child, this.modelType});
  @override
  _CreateModelPageState createState() => _CreateModelPageState();
}

class _CreateModelPageState extends State<CreateModelPage> {

  TextEditingController _modelNameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    ModelBloc modelBloc = Provider.of<ModelBloc>(context);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Hero(
                tag: widget.modelType.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                  child:
                  Image(
                    image: AssetImage(widget.modelType.imageUrl),
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
                  child: Text(widget.modelType.name, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                ),
              ),
              Positioned(
                left: 5,
                top: 5,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: ()=>Navigator.pop(context),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(widget.modelType.longDescription, style: TextStyle(fontSize: 15), textAlign: TextAlign.justify,),
          ),
          widget.child != null ? widget.child : SizedBox(width: 0, height: 0),
          SizedBox(height: 20),
          Hero(
            tag: "createmodeldummy",
            child: SizedBox(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: ButtonTheme(
              height: 60,
              child: FlatButton(
                color: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Text('Create model',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20),),
                onPressed: (){
//                  Navigator.push(context, HeroDialogRoute(
//
//                  ));

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
                                    tag: "createmodeldummy",
                                    child: SizedBox()
                                  ),
                                  Text("Create a new model", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 10),
                                  TextField(
                                    controller: _modelNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(width: 10, style: BorderStyle.solid),
                                      ),
                                      hintText: "Name your model",
                                      fillColor: Colors.white
                                    ),
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
                                          Model model = widget.modelType.createModel(imageUrl: widget.modelType.imageUrl, name: _modelNameController.text);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          await modelBloc.persistModel(model);
//                                          Navigator.push(context,
//                                              MaterialPageRoute(
//                                                  builder: (_)=> widget.modelType.createPage(model: model)
//                                              ));
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),

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
                  return;
                },
              ),
            ),
          ),
          SizedBox(height: 15)
        ],
      )
    );
  }
}
