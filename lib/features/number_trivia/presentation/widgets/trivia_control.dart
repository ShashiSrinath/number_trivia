import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class TriviaControl extends StatefulWidget {
  @override
  _TriviaControlState createState() => _TriviaControlState();
}

class _TriviaControlState extends State<TriviaControl> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          keyboardType: TextInputType.number,
          controller: textController,
          onSubmitted: (_) {
            dispatchGetConcrete();
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Search',
                  style: TextStyle(color: Colors.white),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  dispatchGetConcrete();
                  textController.clear();
                },
              ),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: RaisedButton(
                padding: EdgeInsets.all(15),
                child: Text(
                  'Get Random Trivia',
                ),
                onPressed: () {
                  dispatchGetRandom();
                  textController.clear();
                },
              ),
            )
          ],
        )
      ],
    );
  }

  void dispatchGetConcrete() {
    BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForConcreteNumber(textController.value.text),
    );
  }

  void dispatchGetRandom() {
    BlocProvider.of<NumberTriviaBloc>(context).add(
      GetTriviaForRandomNumber(),
    );
  }
}
