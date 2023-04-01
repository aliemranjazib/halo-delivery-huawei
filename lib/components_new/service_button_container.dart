import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:haloapp/models/app_config_model.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/styles.dart';
import 'package:scroll_indicator/scroll_indicator.dart';

// class ServiceButtonContainer extends StatelessWidget {
//   final List<Service> services;
//   final Function(String) onServiceClick;
//
//   ServiceButtonContainer({@required this.services, this.onServiceClick});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         width: MediaQuery.of(context).size.width,
//         margin: EdgeInsets.symmetric(horizontal: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//           boxShadow: [elevation],
//         ),
//         child: GridView.builder(
//           padding: EdgeInsets.all(6),
//           physics: NeverScrollableScrollPhysics(),
//           shrinkWrap: true,
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 6,
//               mainAxisSpacing: 6,
//               mainAxisExtent: 80),
//           itemBuilder: (_, index) {
//             var model = services[index];
//             return GestureDetector(
//               onTap: () {
//                 onServiceClick(model.iconName);
//               },
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 6),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(2),
//                       child: Image.network(
//                         model.iconUrl,
//                         height: 30,
//                         width: 30,
//                       ),
//                     ),
//                     Text(
//                       AppTranslations.of(context).text(model.iconName),
//                       style: kLabelTextStyle.copyWith(fontSize: 12),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//           itemCount: services.length,
//         )
//         // Row(
//         //   mainAxisAlignment: MainAxisAlignment.spaceAround,
//         //   children: [
//         //     ...services.map(
//         //       (e) => GestureDetector(
//         //         onTap: () {
//         //           onServiceClick(e.iconName);
//         //         },
//         //         child: Container(
//         //           padding: EdgeInsets.symmetric(vertical: 10),
//         //           child: Column(
//         //             children: [
//         //               Image.network(e.iconUrl),
//         //               Text(
//         //                   AppTranslations.of(context).text(e.iconName)
//         //               )
//         //             ],
//         //           ),
//         //         ),
//         //       ),
//         //     ),
//         //   ],
//         // ),
//         );
//   }
// }

class ServiceButtonContainer extends StatefulWidget {
  final List<Service> services;
  final Function(String) onServiceClick;

  ServiceButtonContainer({@required this.services, this.onServiceClick});

  @override
  State<ServiceButtonContainer> createState() => _ServiceButtonContainerState();
}

class _ServiceButtonContainerState extends State<ServiceButtonContainer> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    // print("9999 ${widget.services.last.iconName}");
    return Column(
      children: [
        /// ramadan donation
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //         context, MaterialPageRoute(builder: (_) => CharityMainPage()));
        //   },
        //   child: Container(
        //     margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        //     padding: EdgeInsets.symmetric(vertical: 6),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.all(Radius.circular(10)),
        //       boxShadow: [elevation],
        //     ),
        //     child: Row(
        //       // mainAxisSize: MainAxisSize.max,
        //       children: [
        //         Container(
        //           // width: 200,
        //           // width: double.infinity,
        //           margin: EdgeInsets.only(left: 4),
        //           child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               Text(
        //                 AppTranslations.of(context).text("Ramadan donation"),
        //                 style:
        //                     kLargeTitleBoldTextStyle.copyWith(fontSize: 16.0),
        //                 textAlign: TextAlign.start,
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ],
        //           ),
        //         ),
        //         Spacer(),
        //         // Container(
        //         //   padding: EdgeInsets.all(2),
        //         //   child: Image.network(
        //         //     model.iconUrl,
        //         //     height: 200,
        //         //     width: 75,
        //         //     fit: BoxFit.contain,
        //         //   ),
        //         // ),
        //       ],
        //     ),
        //   ),
        // ),

        Container(
            width: double.infinity,
            height: 200.0,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GridView.custom(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              gridDelegate: SliverQuiltedGridDelegate(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                repeatPattern: QuiltedGridRepeatPattern.inverted,
                pattern: widget.services.length > 5
                    ? [
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 1),
                      ]
                    : [
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 1),
                      ],
              ),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                // if (index == 0) {
                //   count = 2;
                // } else {
                //   count = 1;
                // }
                var model = widget.services[index];
                return GestureDetector(
                  onTap: () {
                    widget.onServiceClick(model.iconName);
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    padding: EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [elevation],
                    ),
                    child: (index == 0)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppTranslations.of(context)
                                          .text(model.iconName),
                                      style: kLargeTitleBoldTextStyle.copyWith(
                                          fontSize: 16.0),
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Container(
                                      // width: 100,
                                      child: Text(
                                        AppTranslations.of(context)
                                            .text(model.iconDes),
                                        style: kAddressPlaceholderTextStyle
                                            .copyWith(fontSize: 12),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    child: Image.network(
                                      model.iconUrl,
                                      height: 110,
                                      width: 150,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            // mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: Container(
                                  // width: 200,
                                  // width: double.infinity,
                                  margin: EdgeInsets.only(left: 4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppTranslations.of(context)
                                            .text(model.iconName),
                                        style: kLargeTitleBoldTextStyle
                                            .copyWith(fontSize: 16.0),
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Container(
                                        constraints:
                                            BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          AppTranslations.of(context)
                                              .text(model.iconDes),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: kAddressPlaceholderTextStyle
                                              .copyWith(fontSize: 12),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Spacer(),
                              Container(
                                padding: EdgeInsets.all(2),
                                child: Image.network(
                                  model.iconUrl,
                                  height: 200,
                                  width: 75,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }, childCount: widget.services.length),
            )

            // ListView.separated(
            //     padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 2.0),
            //     scrollDirection: Axis.horizontal,
            //     itemBuilder: (BuildContext context, int index){
            //       var model = services[index];
            //       return GestureDetector(
            //         onTap: () {
            //           onServiceClick(model.iconName);
            //         },
            //         behavior: HitTestBehavior.translucent,
            //         child: Container(
            //           padding: EdgeInsets.symmetric(vertical: 6),
            //           width: getContainerSize(context),
            //           child: Column(
            //             children: [
            //               Container(
            //                 padding: EdgeInsets.all(2),
            //                 child: Image.network(
            //                   model.iconUrl,
            //                   height: 40,
            //                   width: 40,
            //                 ),
            //               ),
            //               Text(
            //                 AppTranslations.of(context).text(model.iconName),
            //                 style: kLabelTextStyle.copyWith(fontSize: 10.0),
            //                 textAlign: TextAlign.center,
            //                 maxLines: 1,
            //                 overflow: TextOverflow.ellipsis,
            //               )
            //             ],
            //           ),
            //         ),
            //       );
            //     },
            //     separatorBuilder: (BuildContext context, int index){
            //       return Container(
            //         width: 6.0,
            //       );
            //     },
            //     itemCount: services.length
            // )
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     ...services.map(
            //       (e) => GestureDetector(
            //         onTap: () {
            //           onServiceClick(e.iconName);
            //         },
            //         child: Container(
            //           padding: EdgeInsets.symmetric(vertical: 10),
            //           child: Column(
            //             children: [
            //               Image.network(e.iconUrl),
            //               Text(
            //                   AppTranslations.of(context).text(e.iconName)
            //               )
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            ),
        ScrollIndicator(
          scrollController: scrollController,
          width: 50,
          height: 5,
          indicatorWidth: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.grey[300]),
          indicatorDecoration: BoxDecoration(
              color: kColorRed, borderRadius: BorderRadius.circular(10)),
        ),
      ],
    );
  }

  double getContainerSize(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var actualWidth = width - (30.0) - (6.0 * 4);
    // print(width);
    // print((80.0 * 4.5) + (6.0 * 4) + 30.0);
    // print(actualWidth/4.5);
    return (actualWidth / 4.5);
  }
}
