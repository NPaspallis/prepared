import 'package:app/ui/styles/style.dart';
import 'package:flutter/material.dart';

///A widget that displays results for a poll option.
class PollResultsWidget extends StatelessWidget {

  final double _amount;

  const PollResultsWidget(this._amount, {super.key});

  double get amount => _amount;

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
              child: Stack(
                children: [
                  SizedBox(
                    height: 20,
                      child: LinearProgressIndicator(
                        value: _amount,
                        backgroundColor: Colors.grey.shade300,
                        color: secondaryColor,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                  ),
                  Align(alignment: Alignment.center,child: Text("${(_amount * 100).toStringAsFixed(1)}%", style: const TextStyle(fontSize: normalTextSmall)),),
                ],
              ),
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