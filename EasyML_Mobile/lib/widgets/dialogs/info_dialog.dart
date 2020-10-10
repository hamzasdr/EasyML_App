import 'package:flutter/material.dart';


class InformationDialog extends StatefulWidget {
  String tag;
  String text;
  double fontSize;
  InformationDialog({@required this.tag, this.text = "", this.fontSize = 15});
  @override
  _InformationDialogState createState() => _InformationDialogState();
}

class _InformationDialogState extends State<InformationDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          width: MediaQuery.of(context).size.width*0.65,
          child: Material(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).accentColor,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Hero(tag: widget.tag
                        , child: SizedBox()),
                    ListTile(
                      title: Text(widget.text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: widget.fontSize)),
                    ),
                    Center(
                      child: FlatButton(
                        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                        color: Colors.redAccent,
                        onPressed:(){
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text("Ok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    )

                  ]
              ),
            ),
          ),
        )
    );
  }
}
