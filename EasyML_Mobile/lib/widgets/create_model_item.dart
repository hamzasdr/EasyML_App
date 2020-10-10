import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/archive/create_model_page.dart';


class CreateModelItem extends StatefulWidget {
  ModelType modelType;

  CreateModelItem({this.modelType});

  @override
  _CreateModelItemState createState() => _CreateModelItemState();
}

class _CreateModelItemState extends State<CreateModelItem> {
  get child => null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: (){
        print("Tapped ${widget.modelType.name}");
        Navigator.push(context,
        MaterialPageRoute(
          builder: (_)=> CreateModelPage(child: null, modelType: widget.modelType)
        ));
      },

      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
//              color: Colors.white
              ),
              child: Stack(
                children: <Widget>[
                  Hero(
                    tag: widget.modelType.name,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image(
                        image: AssetImage(widget.modelType.imageUrl),
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
                  )
                ],
              ),
            ),
            Container(
              width: 190,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 5),
                  Text(widget.modelType.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), textAlign: TextAlign.left,),
                  SizedBox(height: 5),
                  Text(widget.modelType.shortDescription, style: TextStyle(fontSize: 12), textAlign: TextAlign.left),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
