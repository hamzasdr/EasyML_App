import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/idea.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/Upload_data_Field.dart';
import 'package:provider/provider.dart';

class TrainedModelPage extends StatefulWidget {
  Model model;

  TrainedModelPage({
    @required this.model
  });
  @override
  _TrainedModelPageState createState() => _TrainedModelPageState();
}

class _TrainedModelPageState extends State<TrainedModelPage> {

  static const int _UN_STARTED = -1, _FAILED = -2, _COMPLETE = -3;
  bool _downloadExpanded = false, _predictExpanded = false;
  ReceivePort _port = ReceivePort();
  int _modelDownloadProgress = _UN_STARTED;
  String _modelDownloadTaskId;
  int _predictionDownloadProgress = _UN_STARTED;
  String _predictionDownloadTaskId;

  String _downloadPath;

  @override
  void initState() {
    super.initState();
    getExternalStorageDirectory().then((directory){
      _downloadPath = directory.path;
    });
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      if(id == _modelDownloadTaskId)
        setState((){
          if(status == DownloadTaskStatus.running || status == DownloadTaskStatus.paused)
            _modelDownloadProgress = progress;
          else if(status == DownloadTaskStatus.undefined)
            _modelDownloadProgress = _UN_STARTED;
          else if(status == DownloadTaskStatus.complete)
            _modelDownloadProgress = _COMPLETE;
          else if(status == DownloadTaskStatus.failed)
            _modelDownloadProgress = _FAILED;
          else if(status == DownloadTaskStatus.enqueued)
            _modelDownloadProgress = 0;
        });
      else if(id == _predictionDownloadTaskId)
        setState((){
          if(status == DownloadTaskStatus.running || status == DownloadTaskStatus.paused)
            _predictionDownloadProgress = progress;
          else if(status == DownloadTaskStatus.undefined)
            _predictionDownloadProgress = _UN_STARTED;
          else if(status == DownloadTaskStatus.complete)
            _predictionDownloadProgress = _COMPLETE;
          else if(status == DownloadTaskStatus.failed)
            _predictionDownloadProgress = _FAILED;
          else if(status == DownloadTaskStatus.enqueued)
            _predictionDownloadProgress = 0;
        });
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${widget.model.name}\'s information',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: ListView(
        children: [
          Hero(
            tag: "dialog",
            child: SizedBox(),
          ),
          ExpansionTile(
            onExpansionChanged: (_)=>setState((){_downloadExpanded=_;}),
            leading: Icon(Icons.file_download),
            title: Text('Download trained model'),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left:15),
                    child: Text(
                      'Download trained model',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                    child: Text('The trained model is a python pickle file. In order to use it, open the file in binary read mode and load the pickle model from it.\n'
                        'The model is a Python dictionary containing the trained model, the label encoders (that convert string columns to numbers) and the normalization scalers (which normalize the data) in the following format:'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: HighlightView(
                        '{\n'+
                            '    "model": model,\n'+
                            '    "label_encoders": {\n'+
                            '        "column_name_1": label_encoder1,\n'+
                            '        "column_name_2": label_encoder2,\n'+
                            '        ...\n'+
                            '    },\n'+
                            '    "normalize_scaler": normalize_scaler                       \n'+
                            '}'
                        ,
                        theme: ideaTheme,
                        language: 'python',
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                    child: Text('Example:'),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: HighlightView(
                          // TODO: Examples on how to use label encoders and normalize scaler
                          'import pickle\n'
                              '# make sure to import all the needed libraries, similar to the generated code\n\n'
                              '# the path to the downloaded model\n'
                              'trained_model_file = open("model.pickle", "rb")\n\n'
                              'model_data = pickle.load(trained_model_file, fix_imports=True)\n\n'
                              'trained_model_file.close()\n\n'
                              '# the trained model object\n'
                              'model = model_data["model"]\n\n'
                              '# the label encoders, use them to encode the string columns of data when predicting\n'
                              'label_encoders = model_data["label_encoders"]\n\n'
                              '# the normalize scaler, use it to normalize the data when predicting\n'
                              '# if you haven\'t normalized your data at training, its value will be None\n'
                              'normalize_scaler = model_data["normalize_scaler"]'
                          ,
                          theme: ideaTheme,
                          language: 'python',
                          padding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ButtonTheme(
                        height: 50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                          ),
                          color: Theme.of(context).primaryColor,
                          onPressed: _modelDownloadProgress < 0 ? () async {
                            _modelDownloadTaskId = await modelBloc.downloadModel(widget.model);
                            setState(() {});
                          } : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _modelDownloadProgress >= 0 ? CircularProgressIndicator(value: _modelDownloadProgress/100.0,):
                              Icon(
                                  _modelDownloadProgress == _COMPLETE ? Icons.done:
                                  _modelDownloadProgress == _FAILED ? Icons.close:
                                  Icons.file_download , color: Colors.white, size: 30),
                              SizedBox(width: 5,),
                              Text("Download Model", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _modelDownloadProgress == _COMPLETE ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15.0),
                    child: Center(
                      child: Text(
                          'Model file saved at $_downloadPath/${widget.model.name}.pickle'
                      ),
                    ),
                  ) : SizedBox()
                ],
              )
            ],
            subtitle: _downloadExpanded ? Icon(Icons.keyboard_arrow_up) : SizedBox(),
            trailing: SizedBox(),
          ),
          ExpansionTile(
            onExpansionChanged: (_)=>setState((){_predictExpanded=_;}),
            leading: Icon(FontAwesomeIcons.brain),
            title: Text(widget.model.type.category != ModelCategory.CLUSTERING ? 'Predict' : 'Cluster'),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:15),
                      child: Text(
                        widget.model.type.category != ModelCategory.CLUSTERING ? 'Predict' : 'Cluster',
                        style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                      child: Text( widget.model.type.category != ModelCategory.CLUSTERING ?
                          'Upload the data set you wish to perform a prediction on. '
                          'Make sure it matches the file type and columns for the data set used for training (shown below). '
                          'The dropped columns don\'t need to be included. '
                          'After you upload the data set, a file containing the predictions will be downloaded.' :
                          'Upload the data set you wish to cluster. '
                          'Make sure it matches the file type and columns for the data set used for training (shown below). '
                          'The dropped columns don\'t need to be included. '
                          'After you upload the data set, a file containing the clusters will be downloaded.'
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: UploadDataField(
                          allowedExtensions: DataSet.types[widget.model?.info['dataset_info']['type']]['extensions'],
                          onUploadTapped: (path) async {
                            String taskId = await modelBloc.uploadPredictionDataSet(widget.model, path);
                            setState(() {});
                            return taskId;
                          },
                          onUploadComplete: (UploadTaskResponse response) async {
                            print('Completed');
                            if(response.status == UploadTaskStatus.failed)
                              if(response.statusCode != 201){ // Created
                                Navigator.push(context, HeroDialogRoute(
                                    builder: (BuildContext context) => InformationDialog(
                                      tag: 'dialog',
                                      text:
                                      response.statusCode == 400 ? "The prediction data set uploaded is not compatible with the data set used to train the model":
                                      response.statusCode == 415 ? "The prediction data set file format is not compatible with the data set file format used to train the model":
                                      "An error has occurred :(",
                                    )
                                ));
                              return;
                            }
                            _predictionDownloadTaskId = await modelBloc.downloadPrediction(widget.model, widget.model?.info['dataset_info']['type']);
                            setState(() {});
                          },
                          uploadButtonIcon: _predictionDownloadProgress < 0 ? Icon(FontAwesomeIcons.brain, color: Colors.white, size: 25):
                          CircularProgressIndicator(value: _predictionDownloadProgress/100.0,),
                          uploadButtonText: Text(
                            widget.model.type.category != ModelCategory.CLUSTERING ?
                            (_predictionDownloadProgress < 0 ? "Predict" : "Downloading prediction file"):
                            (_predictionDownloadProgress < 0 ? "Cluster" : "Downloading cluster file"),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),),
                          enabled: (_predictionDownloadProgress < 0),

                      ),
                    ),
                    _predictionDownloadProgress == _COMPLETE ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          'Prediction file saved at $_downloadPath/${widget.model.name} prediction.${widget.model?.info['dataset_info']['type']}'
                        ),
                      ),
                    ) : SizedBox()
                  ],
                )
              ],
            subtitle: _predictExpanded ? Icon(Icons.keyboard_arrow_up) : SizedBox(),
            trailing: SizedBox(),
            ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left:15),
            child: Text(
              'Training Measures',
              style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:17, right: 17),
            child: Text(
              'Scores that indicate how good the trained model is',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),
          ),
          (widget.model?.info['scoring'] as Map<String, dynamic>).keys.isNotEmpty ? Column(
            children: (widget.model?.info['scoring'] as Map<String, dynamic>).entries.where((score) => score.value != null).map((score) => Padding(
              padding: const EdgeInsets.fromLTRB(
                  35, 8, 8 ,8
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('${score.key}:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      score.value is double ? (score.value as double).toStringAsFixed(12) : score.value.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
            )).toList() ?? [

            ],
          ) : Padding(
            padding: EdgeInsets.fromLTRB(
                35, 8, 8 ,8
            ),
            child: Text("A scoring label was not used in training", style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic
            ),),
          ),
          Divider(
            height: 20,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(left:15),
            child: Text(
              'Model Parameters Information',
              style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:17, right: 17),
            child: Text(
              'The parameters used when the model was trained the last time',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),
          ),
          Column(
            children: ((widget.model?.info['params'] ?? []) as List<dynamic>).where((info) => info['value']!=null).map((info) => Padding(
              padding: const EdgeInsets.fromLTRB(
                  35, 8, 8 ,8
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('${info['humanName']}:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
                  ),
                  Expanded(
                    flex: 1,
                    child: info['value'] is bool ? Icon(info['value']?Icons.done:Icons.close) :Text(info['value'].toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 18),),
                  ),
                ],
              ),
            )).toList() ?? [

            ],
          ),
          Divider(
            height: 20,
            thickness: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(left:15),
            child: Text(
              'Data Set Information',
              style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:17, right: 17),
            child: Text(
              'The data set used to train the model the last time',
              style: TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.justify,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:17, right: 17, top: 10, bottom: 10),
            child: RichText(
              text: TextSpan(
                text: 'The data set was ',
                style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500, color: Colors.black),
                children: [
                  TextSpan(
                  text: widget.model?.info['dataset_info']['normalization_method'] == null ? 'not ' : '',
                  style: TextStyle(fontStyle: FontStyle.italic)),
                  TextSpan(
                      text: 'normalized',),
                  TextSpan(
                      text: widget.model?.info['dataset_info']['normalization_method'] == null ? '.' :
                      ' using ${widget.model?.info['dataset_info']['normalization_method'] == 'min_max'?'Minimum/Maximum':'Standard Deviation'} method.',),
                ]
              ),
            ),
          ),
          Column(
            children: (widget.model?.info['dataset_info']['columns'] as List<dynamic>).map((info) => Padding(
              padding: const EdgeInsets.fromLTRB(
                  35, 8, 8 ,8
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text('${info['name']} (${info['type'].toString()})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,
                          fontStyle: (info['name'] == widget.model?.info['y_col'] ||
                              (widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))? FontStyle.italic : FontStyle.normal,
                          color: ((widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))? Colors.grey : null,
                          decoration: (info['name'] == widget.model?.info['y_col']) ? TextDecoration.underline : null
                      ),),
                  ),
                  Expanded(
                    flex: (info['name'] == widget.model?.info['y_col'] ||
                        (widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))? 1 : 0,
                    child: Text(info['name'] == widget.model?.info['y_col'] ?
                    widget.model.type.category == ModelCategory.CLUSTERING ? 'Scoring':'Predicted' :
                      ((widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))?'Dropped':'', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18,
                          fontStyle: (info['name'] == widget.model?.info['y_col'] ||
                              (widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))? FontStyle.italic : FontStyle.normal,
                          color: ((widget.model?.info['to_drop'] as List<dynamic>).contains(info['name']))? Colors.grey : null,
                          decoration: (info['name'] == widget.model?.info['y_col']) ? TextDecoration.underline : null
                      ),),
                  ),
                ],
              ),
            )).toList() ?? [

            ],
          ),

        ],
      ),
    );
  }
}
