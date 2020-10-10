import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/idea.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/Upload_data_Field.dart';
import 'package:provider/provider.dart';

class DataSetPage extends StatefulWidget {
  DataSet dataSet;
  DataSetPage({this.dataSet});
  @override
  _DataSetPageState createState() => _DataSetPageState();
}

class _DataSetPageState extends State<DataSetPage> {

  String _fileName;
  String _path;

  @override
  Widget build(BuildContext context) {
    final DataSetBloc dataSetBloc = Provider.of<DataSetBloc>(context);
    return Scaffold(
//        floatingActionButtonLocation: _BackFloatingActionButtonLocation(),
//        floatingActionButton: FloatingActionButton(
//          child: Icon(Icons.arrow_back),
//          onPressed: () => Navigator.pop(context),
//          backgroundColor: _backButtonBackgroundColor,
//          elevation: 0,
//        ),
        body: Builder(builder: (context){
          return RefreshIndicator(
            onRefresh: () async {
              await dataSetBloc.getDataInformation(widget.dataSet.id);
            },
            color: Theme.of(context).primaryColor,
            child: ListView(
              children: <Widget>[
//            CreateModelPage(modelType: widget.modelType),
                Stack(
                  children: <Widget>[
                    Hero(
                      tag: "dataSet${widget.dataSet.name}${widget.dataSet.id}",
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
                                image: AssetImage("assets/images/${widget.dataSet.type}.png"),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
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
                            Text(widget.dataSet.name,
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
                                textAlign: (MediaQuery.of(context).orientation == Orientation.portrait) ? TextAlign.center : TextAlign.left),
                            Text(DataSet.types[widget.dataSet.type]['name'],
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                                textAlign: (MediaQuery.of(context).orientation == Orientation.portrait) ? TextAlign.center : TextAlign.left),
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
                  ],
                ),
                Hero(
                  tag: "dialog",
                  child: SizedBox(),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(DataSet.types[widget.dataSet.type]['description'])
                    ] + (widget.dataSet.type == 'json' ? <Widget>[
                      Text('Example:'),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: HighlightView(
                            '{\n'
                                '    "columns":["name","age","gender","height"],\n'
                                '    "index":[0,1,2,3,4],\n'
                                '    "data":[\n'
                                '        ["John Doe",  30, "Male",   181.2],\n'
                                '        ["Jack Doe",  43, "Male",   176.7],\n'
                                '        ["Marry Doe", 23, "Female", 165.4],\n'
                                '        ["Phil Doe",  19, "Male",   168.3],\n'
                                '        ["Janet Doe", 32, "Female", 170.0],\n'
                                '    ]\n'
                                '}\n',
                            language: 'json',
                            theme: ideaTheme,
                            padding: EdgeInsets.all(10),
                            textStyle: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Text('Due to a problem, files with a .json extension won\'t upload. Change the format to .txt when uploading',
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),)
                    ] : []),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Upload your data set file in order to view the columns inside it alongside with their types and the number of empty entries. After that, you will be able to use this data set for training.",
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: UploadDataField(
                    width: MediaQuery.of(context).size.width * 0.9,
                    allowedExtensions: DataSet.types[widget.dataSet.type]['extensions'],
                    onUploadTapped: (path) async {
                      print(path);
                      String _taskId = await dataSetBloc.uploadDataSet(widget.dataSet, path);
                      setState(() {});
                      return _taskId;
                    },
                    onChanged: (String newPath, String newFileName) {
//                  setState(() {
//                    _path = newPath;
//                    _fileName = newFileName;
//                    print("current path is ");
//                    print(_path);
//                    print("current Name is ");
//                    print(_fileName);
//                  });
                    },
                    onUploadComplete: (UploadTaskResponse response) async {
                      if(response.status == UploadTaskStatus.failed)
                        if(response.statusCode != 201 && response.statusCode != 200){
                          print(response.response);
                          Navigator.push(context, HeroDialogRoute(
                              builder: (BuildContext context) => InformationDialog(
                                tag: 'dialog',
                                text:
                                response.statusCode == 415 ? "The data set file format does not match the format of a ${DataSet.types[widget.dataSet.type]['name']} file":
                                "An error has occurred :(",
                              )
                          ));
                          return;
                        }
                      await dataSetBloc.handleUploadDataSetResponse(widget.dataSet, response);
                    }
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: Text('Data Set Information', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),),
                ),
                // This will display information about the data set depending on the type of data set it is
                Builder(
                  builder: (BuildContext context){
                      if(widget.dataSet.info == null || widget.dataSet.info.keys.length == 0 )
                        return Center(
                            child: Text('No information. Maybe the data set file isn\'t uploaded?\n\n\n'),
                        );
                      List<Widget> columnChildren = [];
                      if(widget.dataSet.columns != null){
                        columnChildren.add(Text('Columns:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),));
                        columnChildren.addAll(
                          widget.dataSet.columns.map((columnInfo) => ListTile(
                            title: Text('${columnInfo['name']} (${columnInfo['type'] == 'int64' ? 'Integer' : columnInfo['type'] == 'float64' ? 'Float' : 'String'})',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Row(
                                children: <Widget>[
                                  Text('Number of empty (null) entries:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
                                  Text(' ${columnInfo['null_count']}', style: TextStyle(fontSize: 15),),
                                ],
                              ),
                            ),

                          ))
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 15, top: 10, bottom: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: columnChildren,
                        ),
                      );
                  },
                ),
              ]
            ),
          );

        },)
    );
  }
}
