import 'package:flutter/material.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';

// class FoodTypeContainer extends StatelessWidget {
//   FoodTypeContainer({
//     this.foodOptions,
//     this.titleColor,
//     this.onClickIcon,
//   });
//
//   final List<FoodOption> foodOptions;
//   final Color titleColor;
//   final Function(FoodOption) onClickIcon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 10),
//         Container(
//           padding: EdgeInsets.only(left: 10.0,bottom: 6.0),
//           child: Text('What are you craving for?',
//               style: kTitleBoldTextStyle.copyWith(color: titleColor)),
//         ),
//         Container(
//           width: MediaQuery.of(context).size.width,
//           margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
//           decoration: BoxDecoration(
//             color: light3Grey,
//             borderRadius: BorderRadius.all(Radius.circular(5)),
//           ),
//           child: Wrap(
//             children: [
//               ...foodOptions
//                   .map(
//                     (e) => GestureDetector(
//                         onTap: () {
//                           onClickIcon(e);
//                         },
//                         behavior: HitTestBehavior.translucent,
//                         child: Container(
//                           padding: EdgeInsets.symmetric(vertical: 5),
//                           width: (MediaQuery.of(context).size.width - 20) / 4,
//                           child: Column(
//                             children: [
//                               Container(
//                                 margin: EdgeInsets.all(3),
//                                 child: ClipOval(
//                                   child: Image.network(
//                                     e.iconUrl,
//                                     width: 30,
//                                     height: 30,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 e.iconName,
//                                 textAlign: TextAlign.center,
//                                 style: kSmallLabelTextStyle,
//                               )
//                             ],
//                           ),
//                         )),
//                   )
//                   .toList(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

class FoodTypeContainer extends StatelessWidget {
  FoodTypeContainer({
    this.foodOptions,
    this.titleColor,
    this.onClickIcon,
  });

  final List<FoodOption> foodOptions;
  final Color titleColor;
  final Function(FoodOption) onClickIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.only(left: 10.0, bottom: 6.0),
          child: Text(AppTranslations.of(context).text('craving_for'),
              style: kTitleBoldTextStyle.copyWith(color: titleColor)),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 95.0,
          margin: EdgeInsets.symmetric( vertical: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 2.0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index){
              var e = foodOptions[index];
              getContainerSize(context);
              return GestureDetector(
                  onTap: () {
                    onClickIcon(e);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    width: getContainerSize(context),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.0),
                          child: Image.network(
                            e.iconUrl,
                            width: 55.0,
                            height: 55.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          e.iconName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: kSmallLabelTextStyle.copyWith(
                            fontSize: 10.0
                          ),
                        )
                      ],
                    ),
                  )
              );
            },
            separatorBuilder: (BuildContext context, int index){
              return Container(
                width: 0.0,
              );
            },
            itemCount: foodOptions.length
          )
        ),
      ],
    );
  }

  double getContainerSize(BuildContext context){
    var width = MediaQuery.of(context).size.width;
    var actualWidth = width - (50.0) -(6.0*4);
    // print(width);
    // print((80.0 * 4.5) + (6.0 * 4) + 30.0);
    // print(actualWidth/4.5);
    return (actualWidth/4.5);
  }
}
