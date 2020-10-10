import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prototyoe_project_app/blocs/user_bloc.dart';
import 'package:prototyoe_project_app/widgets/dialogs/profile_avatar_dialog.dart';
import 'package:provider/provider.dart';

import 'dialogs/unlogged_dialog.dart';
import 'hero_dialog_route.dart';
import 'dialogs/logged_dialog.dart';

class ProfileAvatar extends StatefulWidget {
  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {

  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return GestureDetector(
      onTap: (){
        Navigator.push(context, HeroDialogRoute(
            builder: (BuildContext context) {
              return ProfileAvatarDialog();
            }
        ));
      },
      child: Builder(
        builder: (BuildContext context){
          if(userBloc.user == null)
            return CircleAvatar(
              child: Icon(Icons.account_circle, color: Theme.of(context).primaryColor, size: 36),
              backgroundColor: Theme.of(context).accentColor,
            );
          return userBloc.user.avatar != null ? CachedNetworkImage(
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
          );
        },
      ),
    );
  }
}