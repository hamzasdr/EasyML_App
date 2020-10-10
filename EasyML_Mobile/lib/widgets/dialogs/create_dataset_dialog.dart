import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/idea.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:hive/hive.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/pages/dataset_page.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_textfield.dart';
import 'package:provider/provider.dart';

class CreateDataSetDialog extends StatefulWidget {
  @override
  _CreateDataSetDialogState createState() => _CreateDataSetDialogState();
}

class _CreateDataSetDialogState extends State<CreateDataSetDialog> {
  List<String> _dataSetTypes;
  int _selectedIndex = 0;
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    _dataSetTypes = DataSet.types.keys.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DataSetBloc dataSetBloc = Provider.of<DataSetBloc>(context);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Hero(tag: "createdatasetdummy", child: SizedBox(),),
        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 170 : 90,
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
                  SizedBox(height: 55),
                  Text(DataSet.types[_dataSetTypes[_selectedIndex]]['name'], style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                    textAlign: TextAlign.center,),
                  SizedBox(height: 10),
                  HelpTextField(
                    controller: _nameController,
                    enableHelp: false,
                    inputType: TextInputType.text,
                    name: "Data Set name",
                    width: MediaQuery.of(context).size.width*0.75 - 40,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 0,
                        maxHeight: (MediaQuery.of(context).orientation == Orientation.portrait) ? 150 : 60
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Text(DataSet.types[_dataSetTypes[_selectedIndex]]['description'],
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.justify,),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: FlatButton(
                      onPressed: () async {
                        DataSet dataSet = DataSet(
                          id: -1,
                          name: _nameController.text,
                          type: _dataSetTypes[_selectedIndex],
                          info: null
                        );
                        dataSet = await dataSetBloc.postNetworkDataSet(dataSet);
                        if(dataSet != null){
                          Navigator.pop(context);
                          DataSetPage(dataSet: dataSet);
                        }
                      },
                      child: Text("Create", style: TextStyle(fontSize: 15),),
                    ),
                  ),
                  SizedBox(height: 10),

                ],
              ),
            ),
          ),
        ),
        Positioned(
            top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 100 : 20,
            child: Container(
              width: MediaQuery.of(context).size.width*0.75,
              height: 120,
              child: Swiper(
                itemCount: _dataSetTypes.length,
                viewportFraction: 0.8,
                scale: 0.9,
                itemHeight: 120,
                itemWidth: 120,
                containerHeight: 120,
                containerWidth: MediaQuery.of(context).size.width*0.75,
                layout: SwiperLayout.CUSTOM,
                customLayoutOption: CustomLayoutOption(
                    startIndex: -1,
                    stateCount: 3
                ).addOpacity([0.5, 1, 0.5])
                    .addTranslate([Offset(-92.5, 25), Offset(0, 0), Offset(92.5, 25)])
                    .addScale([0.5, 1, 0.5], Alignment.bottomCenter),
                itemBuilder: (BuildContext context, int index) {
                  return FittedBox(
                    fit: BoxFit.fill,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(120),
                              child: Image(
                                image: AssetImage("assets/images/${_dataSetTypes[index]}.png"),
                                fit: BoxFit.contain,
                              ),
                              clipBehavior: Clip.antiAlias,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                onIndexChanged: (index){
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            )
        ),
        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 180 : 100,
          right: ((MediaQuery.of(context).size.width*0.25)/2)+10,
          child: GestureDetector(
              child: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
              onTap: ()=>Navigator.pop(context)
          ),
        )
      ],
    );
  }
}
