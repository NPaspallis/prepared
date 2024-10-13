import 'package:flutter/material.dart';

///A widget that displays results for a poll option.
class MultipollResultsWidget extends StatelessWidget {

  final int _numOfVotes;

  const MultipollResultsWidget(this._numOfVotes, {super.key});

  int get numOfVotes => _numOfVotes;

  @override
  Widget build(BuildContext context) {
    // print("AMOUNT: " + _amount.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: Text("Voted by $_numOfVotes users", style: const TextStyle(fontSize: 15, color: Colors.deepOrange),),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10),
            //   child: Text("${(_amount * 100).toStringAsFixed(1)}%", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12)),
            // ),
          ],
        ),
      ],
    );
  }

}