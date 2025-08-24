import 'package:common/arch/domain/model/baby_data.dart';
import 'package:common/arch/ui/widget/_basic_widget.dart';
import 'package:common/config/_config.dart';
import 'package:common/res/string/_string.dart';
import 'package:common/res/theme/_theme.dart';
import 'package:common/util/assets.dart';
import 'package:common/util/times.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/ui/base/live_data_observer.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChildrenListOverlay extends StatefulWidget {
  final List<BabyOverlayData> bornBabyList;
  final List<BabyOverlayData> unbornBabyList;
  final void Function(BabyOverlayData, bool isBorn)? onItemClick;
  final void Function(bool isBorn)? onAddItemClick;
  final LiveData<int>? selectedIndex;
  final bool isSelectedIndexOwner;

  ChildrenListOverlay({
    required this.bornBabyList,
    required this.unbornBabyList,
    this.onItemClick,
    this.onAddItemClick,
    this.selectedIndex,
    bool? isSelectedIndexOwner,
  }): isSelectedIndexOwner = isSelectedIndexOwner ?? selectedIndex == null
  ;

  @override
  _ChildrenListOverlayState createState() => _ChildrenListOverlayState(
    bornBabyList: bornBabyList,
    unbornBabyList: unbornBabyList,
    onItemClick: onItemClick,
    onAddItemClick: onAddItemClick,
    selectedIndex: selectedIndex,
    isSelectedIndexOwner: isSelectedIndexOwner,
  );
}

class _ChildrenListOverlayState extends State<ChildrenListOverlay> {
  final List<BabyOverlayData> bornBabyList;
  final List<BabyOverlayData> unbornBabyList;
  final void Function(BabyOverlayData, bool isBorn)? onItemClick;
  final void Function(bool isBorn)? onAddItemClick;
  final LiveData<int>? selectedIndex;
  final bool isSelectedIndexOwner;

  _ChildrenListOverlayState({
    required this.bornBabyList,
    required this.unbornBabyList,
    required this.onItemClick,
    required this.onAddItemClick,
    required this.selectedIndex,
    required this.isSelectedIndexOwner,
  });

  @override
  void dispose() {
    if(isSelectedIndexOwner) {
      selectedIndex?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10,),
          ChildrenSingleListOverlay(
            header: Strings.my_pregnancy,
            selectedIndex: selectedIndex,
            dataList: unbornBabyList,
            datePrefix: "${Strings.hpl}: ",
            // Hide add button if there is already an active (unborn) pregnancy
            addItemStr: unbornBabyList.isEmpty ? Strings.add_pregnancy : null,
            onAddItemClick: (onAddItemClick != null && unbornBabyList.isEmpty) ? () {
              onAddItemClick!(false); // false => unborn context
            } : null,
            onItemClick: onItemClick != null
                ? (data) => onItemClick!.call(data, false)
                : null,
          ),
          SizedBox(height: 10,),
          ChildrenSingleListOverlay(
            header: Strings.my_baby,
            startIndex: unbornBabyList.length,
            selectedIndex: selectedIndex,
            dataList: bornBabyList,
            datePrefix: "${Strings.born}: ",
            addItemStr: Strings.add_baby,
            onAddItemClick: onAddItemClick != null ? () {
              onAddItemClick!(true);
            } : null,
            onItemClick:  onItemClick != null
                ? (data) => onItemClick!.call(data, true)
                : null,
          ),
          SizedBox(height: 10,),
        ],
      ),
    );
  }
}


class ChildrenSingleListOverlay extends StatelessWidget {
  final String header;
  final String datePrefix;
  final List<BabyOverlayData> dataList;
  final void Function(BabyOverlayData)? onItemClick;
  final void Function()? onAddItemClick;
  final String? addItemStr;
  final int startIndex;
  final LiveData<int>? selectedIndex;

  ChildrenSingleListOverlay({
    required this.header,
    required this.dataList,
    this.startIndex = 0,
    this.datePrefix = "",
    this.onItemClick,
    this.onAddItemClick,
    this.addItemStr,
    this.selectedIndex
  });

  int getChildViewIndex(int position) => position +startIndex;
  //int getChildDataIndex(int position) => position -startIndex;

  @override
  Widget build(BuildContext context) {
    final headerWidget = Text(
      header,
      style: SibTextStyles.size_0_bold,
      textAlign: TextAlign.center,
    );

    final listWidget = dataList.isNotEmpty ? List<Widget>.generate(dataList.length, (i) {
      final e = dataList[i];
      return Container(
        decoration: BoxDecoration(
          color: grey_calm,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(vertical: 5,),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onItemClick != null ? () {
              onItemClick!.call(e);
              //selectedIndex.value = getChildViewIndex(i);
            } : null,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                child: ClipOval(
                  child: SibImages.resolve(
                    e.img,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              title: Text(
                e.name,
                style: SibTextStyles.size_0_bold,
              ),
              subtitle: Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                  _getDateStr(e.date),
                  style: SibTextStyles.size_min_1_grey,
                ),
              ),
              trailing: selectedIndex != null ? LiveDataObserver<int>(
                liveData: selectedIndex!,
                builder: (ctx, u) {
                  //prind("ChildrenSingleListOverlay u= $u i= $i getChildViewIndex(i)= ${getChildViewIndex(i)}");
                  if(u == null) return defaultEmptyWidget();
                  return u == getChildViewIndex(i) ? Icon(
                    Icons.check_circle,
                    color: Manifest.theme.colorPrimary,
                  ) : defaultEmptyWidget();
                },
              ) : null,
            ),
          ),
        ),
      );
    }) : <Widget>[defaultNoData()];

    if(onAddItemClick != null) {
      listWidget.add(
        addItemStr != null ? ActionChip(
          onPressed: onAddItemClick!,
          backgroundColor: Manifest.theme.colorPrimary,
          label: Text(
            addItemStr!,
            style: SibTextStyles.size_min_1_colorOnPrimary,
          ),
          avatar: Icon(
            Icons.add_rounded,
            size: 27,
            color: white,
          ),
        ) : InkResponse(
          onTap: onAddItemClick!,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Manifest.theme.colorPrimary,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 27,
              color: Manifest.theme.colorPrimary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        headerWidget,
        SizedBox(height: 5,),
        ...listWidget,
      ],
    );
  }

  String _getDateStr(DateTime date) => datePrefix.isNotEmpty
      ? "$datePrefix${syncFormatTime(date)}"
      : syncFormatTime(date);
}