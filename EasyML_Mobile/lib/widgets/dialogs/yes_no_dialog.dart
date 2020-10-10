import 'package:flutter/material.dart';

class YesNoDialog extends StatefulWidget {
  String text, subtext, tag;
  Function action;

  YesNoDialog({
    @required this.tag,
    @required this.text,
    this.subtext,
    @required this.action
  });

  @override
  _YesNoDialogState createState() => _YesNoDialogState();
}

class _YesNoDialogState extends State<YesNoDialog> {
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
                    Hero(tag: widget.tag, child: SizedBox()),
                    ListTile(
                      title: Text(widget.text, style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: widget.subtext != null ? Text(widget.subtext) : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                          color: Colors.white,
                          onPressed:(){
                            Navigator.pop(context);

                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("No", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                        FlatButton(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                          color: Colors.redAccent,
                          onPressed: widget.action,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("Yes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        )
                      ],
                    )

                  ]
              ),
            ),
          ),
        )
    );
  }
}
