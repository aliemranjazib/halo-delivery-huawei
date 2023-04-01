import 'package:flutter/material.dart';
import 'package:haloapp/utils/constants/fonts.dart';

class HorizontalCard extends StatelessWidget {
  HorizontalCard({
    this.image,
    this.name,
    this.onClick,
    this.cardHeight,
    this.cardWidth
  });

  final String image;
  final String name;
  final Function onClick;
  final double cardHeight;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.only(right: 16),
        width: MediaQuery.of(context).size.width / 3.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                height: cardHeight,
                width: cardWidth,
              ),
            ),
            Text(
              name+"\n",
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(fontSize: 10.0, fontFamily: poppinsBold,height: 1.1,),
            ),
          ],
        ),
      ),
    );
  }
}
