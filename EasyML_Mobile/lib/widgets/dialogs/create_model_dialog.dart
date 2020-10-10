import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:prototyoe_project_app/blocs/dataset_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_bloc.dart';
import 'package:prototyoe_project_app/blocs/model_type_bloc.dart';
import 'package:prototyoe_project_app/exceptions.dart';
import 'package:prototyoe_project_app/models/data_set.dart';
import 'package:prototyoe_project_app/models/model.dart';
import 'package:prototyoe_project_app/models/model_type.dart';
import 'package:prototyoe_project_app/pages/dataset_page.dart';
import 'package:prototyoe_project_app/pages/model_page.dart';
import 'package:prototyoe_project_app/widgets/dialogs/info_dialog.dart';
import 'package:prototyoe_project_app/widgets/hero_dialog_route.dart';
import 'package:prototyoe_project_app/widgets/inputs/help_textfield.dart';
import 'package:provider/provider.dart';

class CreateModelDialog extends StatefulWidget {

  @override
  _CreateModelDialogState createState() => _CreateModelDialogState();
}

class _CreateModelDialogState extends State<CreateModelDialog> with TickerProviderStateMixin{
  int _selectedIndex = 0;
  static const bool CAROUSEL = true, GRID = false;
  bool _view = CAROUSEL;
  TextEditingController _nameController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ModelBloc modelBloc = Provider.of<ModelBloc>(context);
    final ModelTypeBloc modelTypeBloc = Provider.of<ModelTypeBloc>(context);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Hero(tag: "createmodeldummy", child: SizedBox(),),
        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 170 : (_view == CAROUSEL ? 90 : 35),
          child: Container(
            width: MediaQuery.of(context).size.width*0.8,
            child: Material(
              textStyle: TextStyle(fontSize: 16, color: Colors.black),
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).accentColor,
              child: AnimatedSize(
                vsync: this,
                duration: Duration(milliseconds: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: _view == CAROUSEL ? 55 : 15),
                    _view == CAROUSEL ? Text(modelTypeBloc.modelTypes[_selectedIndex].name, style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                      textAlign: TextAlign.center,) : SizedBox(),
                    SizedBox(height: _view == CAROUSEL ? 5 : 0,),
                    _view == CAROUSEL ? Text(
                      modelTypeBloc.modelTypes[_selectedIndex].categoryName,
                      style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                      textAlign: TextAlign.center,) : SizedBox(),
                    SizedBox(height: 10),
                    HelpTextField(
                      controller: _nameController,
                      enableHelp: false,
                      inputType: TextInputType.text,
                      name: "Model name",
                      width: MediaQuery.of(context).size.width*0.8 - 50,
                    ),
                    SizedBox(height: _view == CAROUSEL ? 10 : 2.5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 0,
                          maxHeight: (MediaQuery.of(context).orientation == Orientation.portrait) ?
                          (_view == CAROUSEL ? 150 : 250) : (_view == CAROUSEL ? 60 : 200)
                        ),
                        child: _view == CAROUSEL ? SingleChildScrollView(
                          child: Center(
                            child:  Text(modelTypeBloc.modelTypes[_selectedIndex].longDescription, style: TextStyle(fontSize: 14), textAlign: TextAlign.justify,)
                            ,
                          ),
                        ):
                        GridView.count(
                          crossAxisCount: (MediaQuery.of(context).orientation == Orientation.portrait) ? 3 : 5,
                          childAspectRatio: (MediaQuery.of(context).orientation == Orientation.portrait) ? 0.7 : 0.8,
                          children: modelTypeBloc.modelTypes.map(
                              (type) => GridTile(
                                child: Container(
                                  padding: EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: _selectedIndex >= 0 && type == modelTypeBloc.modelTypes[_selectedIndex] ? Color(0xFFE0E0E0) : null,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => setState(()=> _selectedIndex=modelTypeBloc.modelTypes.indexOf(type) ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Align(
                                                heightFactor: 0.75,
                                                widthFactor: 0.75,
                                                alignment: Alignment.center,
                                                child: Image(
                                                  image: AssetImage(type.imageUrl),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                            ),
                                            Positioned(
                                              bottom: 5,
                                              left: 0,
                                              right: 0,
                                              child: SizedBox(
                                                  width: 12.5,
                                                  height: 12.5,
                                                  child:
                                                  type.category == ModelCategory.REGRESSION ?
                                                  Image.asset('assets/images/regression.png'):
                                                  type.category == ModelCategory.CLASSIFICATION ?
                                                  Image.asset('assets/images/classification.png'):
                                                  Image.asset('assets/images/clustering.png')
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(type.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                                        SizedBox(height: 2,),
                                        Text(type.categoryName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300), textAlign: TextAlign.center,)
                                      ],
                                    ),
                                  ),
                                ),
                              )
                          ).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          child: Text(_view == CAROUSEL ? 'Switch to brief view': 'Switch to detailed view'),
                          onPressed: (){
                              setState(() {
                                _view = !_view;
                                if(_view == CAROUSEL)
                                  _selectedIndex = 0;
                                else
                                  _selectedIndex = -1;
                              });
                          },
                        ),
                        FlatButton(
                          onPressed: (_loading || _selectedIndex <= -1) ? null : () async {
                            if((_nameController.text ?? '' )== '')
                              return;
                            if(_loading)
                              return;
                            setState(() {
                              _loading = true;
                            });
                            Model model = modelTypeBloc.modelTypes[_selectedIndex].createModel(
                                imageUrl: modelTypeBloc.modelTypes[_selectedIndex].imageUrl,
                                name: _nameController.text
                            );
                            try {
                              await modelBloc.persistModel(model);
                            } on DuplicateNameException catch (e) {
                              Navigator.push(context, HeroDialogRoute(
                                builder: (BuildContext context) => InformationDialog(
                                  tag: 'duplicate_model_err',
                                  text: "A model with the same name already exists",
                                )
                              ));
                              return;
                            } finally {
                              _loading = false;
                            }
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (_)=> ModelPage(model: model)
                                ));
                          },
                          child: Text("Create", style: TextStyle(fontSize: 15),),
                        ),
                      ],
                    ),
                    Hero(tag: 'duplicate_model_err', child: SizedBox(height: 10)),

                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
            top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 100 : 20,
            child: _view == CAROUSEL ? Container(
              width: MediaQuery.of(context).size.width*0.75,
              height: 120,
              child: Swiper(
                itemCount: modelTypeBloc.modelTypes.length,
                viewportFraction: 0.8,
                scale: 0.9,
                itemHeight: 120,
                itemWidth: 120,
                containerHeight: 120,
                containerWidth: MediaQuery.of(context).size.width*0.75,

                layout: SwiperLayout.CUSTOM,
                customLayoutOption: (MediaQuery.of(context).orientation == Orientation.portrait) ?
                CustomLayoutOption(
                    startIndex: -1,
                    stateCount: 3
                ).addOpacity([0.5, 1, 0.5])
                    .addTranslate([Offset(-92.5, 25), Offset(0, 0), Offset(92.5, 25)])
                    .addScale([0.5, 1, 0.5], Alignment.bottomCenter) :
                CustomLayoutOption(
                    startIndex: -2,
                    stateCount: 5
                ).addOpacity([0.5, 0.5, 1, 0.5, 0.5])
                    .addTranslate([Offset(-145, 35), Offset(-92.5, 25), Offset(0, 0), Offset(92.5, 25), Offset(145, 35)])
                    .addScale([0.3, 0.5, 1, 0.5, 0.3], Alignment.bottomCenter),
                itemBuilder: (BuildContext context, int index) {
                  return FittedBox(
                    fit: BoxFit.fill,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(120),

                          child: Align(
                            heightFactor: 0.8,
                            widthFactor: 0.8,
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage(modelTypeBloc.modelTypes[index].imageUrl),
                              fit: BoxFit.contain,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                        ),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                              width: 75,
                              height: 75,
                              child:
                              modelTypeBloc.modelTypes[index].category == ModelCategory.REGRESSION ?
                              Image.asset('assets/images/regression.png'):
                              modelTypeBloc.modelTypes[index].category == ModelCategory.CLASSIFICATION ?
                              Image.asset('assets/images/classification.png'):
                              Image.asset('assets/images/clustering.png')
                          ),
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
            ) : SizedBox()
        ),
        Positioned(
          top: (MediaQuery.of(context).orientation == Orientation.portrait) ? 180 : (_view == CAROUSEL ? 100 : 45),
          right: ((MediaQuery.of(context).size.width*0.2)/2)+10,
          child: GestureDetector(
              child: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
              onTap: ()=>Navigator.pop(context)
          ),
        )
      ],
    );
  }
}
