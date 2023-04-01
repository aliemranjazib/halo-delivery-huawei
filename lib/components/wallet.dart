import 'package:flutter/material.dart';

class Wallet extends StatelessWidget {
  Wallet({
    this.balance,
  });

  final String balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.wallet_membership,
              color: Colors.yellow,
            ),
          ),
          Text(
            balance,
            style: TextStyle(
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
