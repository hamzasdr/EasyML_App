import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:provider/provider.dart';

class UploadDataField extends StatefulWidget {
  Function onChanged;
  String name;
  double width;
  List<String> allowedExtensions;
  Function onUploadTapped;
  Function onUploadComplete;
  Widget uploadButtonIcon;
  Widget uploadButtonText;
  bool enabled;
  FileType type;
  // DataSet dataSet;
  UploadDataField({
    this.allowedExtensions,
    @required this.onUploadTapped,
    @required this.onUploadComplete,
    this.name = 'Upload',
    this.width = 350,
    this.onChanged,
    this.uploadButtonIcon,
    this.uploadButtonText,
    this.enabled = true,
    this.type = FileType.custom
  });

  @override
  _UploadDataFieldState createState() => _UploadDataFieldState();
}

class _UploadDataFieldState extends State<UploadDataField> {
  static const int _UN_STARTED = -1, _FAILED = -2, _COMPLETE = -3;
  String _fileName;
  String _path;
  int _uploadProgress = _UN_STARTED;
  String _taskId;
  StreamSubscription uploadStateSubscription, uploadCompletionSubscription;

  @override
  void initState() {
    uploadStateSubscription = FlutterUploader().progress.listen((progress) {
      UploadTaskStatus status = progress.status;
      if(progress.taskId == _taskId){
        setState(() {
          if(status == UploadTaskStatus.running || status == UploadTaskStatus.paused)
            _uploadProgress = progress.progress;
          else if(status == UploadTaskStatus.undefined)
            _uploadProgress = _UN_STARTED;
          else if(status == UploadTaskStatus.complete)
            _uploadProgress = _COMPLETE;
          else if(status == UploadTaskStatus.failed)
            _uploadProgress = _FAILED;
          else if(status == UploadTaskStatus.enqueued)
            _uploadProgress = 0;
        });
      }
    });
    uploadCompletionSubscription = FlutterUploader().result.listen((result) async {
      if(result.taskId == _taskId){
        UploadTaskStatus status = result.status;
        print(result.status);
        setState(() {
          if(status == UploadTaskStatus.failed)
            _uploadProgress = _FAILED;
          else
            _uploadProgress = _COMPLETE;
        });
        _taskId = null;
        await widget.onUploadComplete(result);
      }
    }, onError: (ex, stacktrace) async {
      UploadException exception = ex as UploadException;
        if(exception.taskId == _taskId){
          await widget.onUploadComplete(UploadTaskResponse(
              taskId: exception.taskId,
              statusCode: exception.statusCode,
              status: exception.status,
              response: exception.message,
              tag: exception.tag
          ));
          setState(() {
            if(exception.status == UploadTaskStatus.undefined)
              _uploadProgress = _UN_STARTED;
            else if(exception.status == UploadTaskStatus.complete)
              _uploadProgress = _COMPLETE;
            else if(exception.status == UploadTaskStatus.failed)
              _uploadProgress = _FAILED;
          });
          _taskId = null;
        }

    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    uploadStateSubscription.cancel();
    uploadCompletionSubscription.cancel();
  }

  void _openFileExplorer(BuildContext context) async {
    try {
      setState(() {
        _taskId = null;
      });
      String _tempPath = await FilePicker.getFilePath(type: widget.type,);
      if(_tempPath != null && widget.type == FileType.custom){
        String ext = extension(_tempPath).toLowerCase();
        if(!widget.allowedExtensions.contains(ext.substring(1))){
          _tempPath = null;
          Navigator.push(context, new HeroDialogRoute(
            builder: (BuildContext context) => InformationDialog(
              tag: 'upload_invalid',
              text: "The selected file type isn't supported for this type",
            )
          ));
        }
      }
      _path = _tempPath ?? _path;
      setState(() {
        _uploadProgress = _UN_STARTED;
      });
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      if (widget.onChanged != null)
        widget.onChanged(_path, _fileName);
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.uploadButtonIcon = widget.uploadButtonIcon ?? Icon(Icons.file_upload, color: Colors.white, size: 30);
    widget.uploadButtonText = widget.uploadButtonText ?? Text('Upload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white));
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              // border: Border.fromBorderSide(BorderSide(width: 1)),
              color: Colors.white,
              borderRadius: BorderRadius.circular(15)
            ),
            //width: widget.width,
            child:
            ListTile(
              title: _path != null ? Text(basename(_path)): Text('Tap to select a file'),
              trailing:
              _taskId == null ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _path != null ? GestureDetector(
                        onTap: () => setState((){ _path = null; _uploadProgress = _UN_STARTED;}),
                        child: Icon(Icons.cancel, color: Colors.black,),
                      ) : SizedBox(),
                    ],
                  ),
                ],
              ): SizedBox(),
              onTap: _taskId == null ? ()=>_openFileExplorer(context) : null,
            )
          ),
          SizedBox(
            height: 10,
          ),
          ButtonTheme(
            height: 50,
            // minWidth: widget.width,
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _uploadProgress >= 0 ? Stack(
                    children: <Widget>[
                      Hero(
                        tag: 'upload_invalid',
                        child: SizedBox(),
                      ),
                      Container(
                        child: CircularProgressIndicator(
                          value: (_uploadProgress/100.0),
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).accentColor),
                          backgroundColor: Theme.of(context).primaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 1,),
                      Positioned(
                        top: 11.5,
                        left: 9,
                        child: Text(_uploadProgress < 100 ?"$_uploadProgress%" : "",
                          style: TextStyle(fontSize: 11, color: Theme.of(context).accentColor),
                        ),
                      )
                    ],
                  ):
                  _uploadProgress == _COMPLETE ? Icon(Icons.done, color: Colors.white, size: 30,):
                  _uploadProgress == _FAILED ? Icon(Icons.close, color: Colors.white, size: 30,):
                  widget.uploadButtonIcon,

                  SizedBox(width: 10,),
                  widget.uploadButtonText
                ],
              ),
              color: Theme.of(context).primaryColor,
              disabledColor: Colors.grey,
              onPressed: !widget.enabled ||_path == null || _taskId != null ? null : () async {
                _taskId = await widget.onUploadTapped(_path);
                setState(() { });
              } ,
            ),
          )
        ],
      ),
    );
  }

}
