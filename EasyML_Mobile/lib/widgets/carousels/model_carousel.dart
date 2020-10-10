import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/widgets/dialogs/create_model_dialog.dart';
import 'package:provider/provider.dart';
import 'package:prototyoe_project_app/widgets/model_item.dart';

import '../hero_dialog_route.dart';

class ModelCarousel extends StatefulWidget {
  @override
  _ModelCarouselState createState() => _ModelCarouselState();
}

class _ModelCarouselState extends State<ModelCarousel> {
  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("My models", style: TextStyle(fontSize: 30,
                fontWeight: FontWeight.w600,
              ),),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, new HeroDialogRoute(
                      builder: (BuildContext context){
                        return CreateModelDialog();
                      }
                  ));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_circle),
                    Text(" New model", style: TextStyle(fontWeight: FontWeight.w500),),
                    Hero(tag: "createmodeldummy", child: SizedBox(),)
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
//          color: Colors.red,
          height: 275,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: modelBloc.models.length > 0 ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: modelBloc.models.length,
                itemBuilder: (BuildContext context, int index) {
                  return ModelItem(model: modelBloc.models[index],);
                }
            ) : Center(
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, new HeroDialogRoute(
                      builder: (BuildContext context){
                        return CreateModelDialog();
                      }
                  ));
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: <Widget>[
                    SizedBox(height: 45),
                    Icon(FontAwesomeIcons.frown, size: 36, color: Colors.grey,),
                    Text("No models\nTap to add a new model", style: TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center,),

                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
