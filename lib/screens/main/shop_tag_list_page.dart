import 'package:flutter/material.dart';
import 'package:haloapp/components/model_progress_hud.dart';
import 'package:haloapp/utils/app_translations/app_translations.dart';
import 'package:haloapp/utils/constants/custom_colors.dart';
import 'package:haloapp/utils/constants/fonts.dart';
import 'package:haloapp/utils/constants/styles.dart';

class ShopTagListPage extends StatefulWidget {
  static const String id = '/shopTagList';

  ShopTagListPage({
    this.tags,
  });

  final List<dynamic> tags;

  @override
  _ShopTagListPageState createState() => _ShopTagListPageState();
}

class _ShopTagListPageState extends State<ShopTagListPage> {
  bool _showSpinner = false;

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    print('init state, shop tag list page');
    print(widget.tags);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _showSpinner,
      child: Scaffold(
        appBar: AppBar(
          leading: Container(
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: arrowBack),
          ),
          actions: [],
          title: Text(AppTranslations.of(context).text('shop_tag'),
              textAlign: TextAlign.center, style: kAppBarTextStyle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.tags != null)
                    ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.tags.length,
                      itemBuilder: (_, index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          child: Text(
                            widget.tags[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: poppinsSemiBold,
                            ),
                          ),
                        );
                      },
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
