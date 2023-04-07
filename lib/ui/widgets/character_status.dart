import 'package:flutter/material.dart';

enum LiveState { alive, dead, unknown }

class CharacterStatus extends StatelessWidget {
  final LiveState liveState;
  const CharacterStatus({Key? key, required this.liveState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.circle,
          size: 11,
          color: liveState == LiveState.alive
              ? Colors.lightGreenAccent[400]
              : liveState == LiveState.dead
                  ? Colors.red
                  : Colors.white,
        ),
        SizedBox(
          width: 6,
        ),
        Text(
          liveState == LiveState.alive
              ? 'Alive'
              : liveState == LiveState.dead
                  ? 'Dead'
                  : 'Unknown',
          style: Theme.of(context).textTheme.bodyText1,
        )
      ],
    );
  }
}
