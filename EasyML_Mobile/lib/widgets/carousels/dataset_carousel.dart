import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/widgets/dataset_item.dart';
import 'package:prototyoe_project_app/widgets/dialogs/create_dataset_dialog.dart';
import 'package:provider/provider.dart';

import '../hero_dialog_route.dart';

class DataSetCarousel extends StatefulWidget {
  @override
  _DataSetCarouselState createState() => _DataSetCarouselState();
}

class _DataSetCarouselState extends State<DataSetCarousel> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DataSetBloc dataSetBloc = Provider.of<DataSetBloc>(context);
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text("My data sets", style: TextStyle(fontSize: 30,
                fontWeight: FontWeight.w600,
              ),),
              GestureDetector(
                onTap: userBloc.user == null ? null : (){
                  Navigator.push(context, new HeroDialogRoute(
                      builder: (BuildContext context){
                        return CreateDataSetDialog();
                      }
                  ));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add_circle, color: userBloc.user == null ? Colors.grey : Theme.of(context).primaryColor,),
                    Text(" New data set", style: TextStyle(fontWeight: FontWeight.w500, color: userBloc.user == null ? Colors.grey : Theme.of(context).primaryColor),),
                    Hero(tag: "createdatasetdummy", child: SizedBox(),)
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
            child: userBloc.user == null ?
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: <Widget>[
                  SizedBox(height: 45),
                  Icon(Icons.cloud_off, size: 36, color: Colors.grey,),
                  Text("You need to be logged in to view your data sets", style: TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center,),

                ],
              ),
            ):
            dataSetBloc.dataSets.length > 0 ? ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataSetBloc.dataSets.length,
                itemBuilder: (BuildContext context, int index) {
                  return DataSetItem(dataSet: dataSetBloc.dataSets[index],);
                }
            ):
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: <Widget>[
                  SizedBox(height: 45),
                  Icon(FontAwesomeIcons.frown, size: 36, color: Colors.grey,),
                  Text("No data sets", style: TextStyle(fontSize: 18, color: Colors.grey)),

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
