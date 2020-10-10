import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/widgets/dialogs/unlogged_dialog.dart';
import 'package:provider/provider.dart';

import 'logged_dialog.dart';

class ProfileAvatarDialog extends StatefulWidget {
  @override
  _ProfileAvatarDialogState createState() => _ProfileAvatarDialogState();
}

class _ProfileAvatarDialogState extends State<ProfileAvatarDialog> {
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[

        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 170 : 95,
          child: Container(
            width: MediaQuery.of(context).size.width*0.75,
            decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(25)
            ),
            child: Material(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).accentColor,
                child: userBloc.user == null ? UnloggedDialog() : LoggedDialog(update: ()=>setState((){}),)
            ),
          ),
        ),
        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 100 : 30,
          child: Hero(
            tag: "profile",
            child: Container(
              width: 100,
              height: 100,
              child: FittedBox(
                  fit: BoxFit.fill,
                  child: (userBloc.user == null) ?
                  CircleAvatar(
                    child: Icon(Icons.account_circle, color: Theme.of(context).primaryColor, size: 36),
                    backgroundColor: Theme.of(context).accentColor,
                  ) :
                  userBloc.user.avatar != null ? CachedNetworkImage(
                    imageUrl: userBloc.user.avatar,
                    imageBuilder: (BuildContext context, ImageProvider provider) =>
                        CircleAvatar(
                          backgroundImage: provider,
                          backgroundColor: Theme.of(context).accentColor,
                        ),
                    placeholder: (BuildContext context, url) => CircleAvatar(
                      child: Icon(Icons.account_circle, color: Colors.indigo, size: 36),
                      backgroundColor: Theme.of(context).accentColor,
                    )
                    ,
                  ): CircleAvatar(
                    child: Icon(Icons.account_circle, color: Colors.indigo, size: 36),
                    backgroundColor: Theme.of(context).accentColor,
                  )
              ),
            ),
          ),
        ),
      ],
    );
  }
}
