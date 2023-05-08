import 'package:client/common/const/colors.dart';
import 'package:client/common/layout/default_layout.dart';
import 'package:client/restaurant/view/restaurant_screen.dart';
import 'package:flutter/material.dart';

class RootTab extends StatefulWidget {
  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin {
  late TabController _controller;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // vsync : 현재 컨트롤러를 선언하는 State를 넣어주면 된다. => this
    // this를 사용하기 위해서는 특정 기능을 가져야 하기 때문에 with SingleTickerProviderStateMixin을 붙여줘야 함
    _controller = TabController(length: 4, vsync: this);

    _controller.addListener(tabListener);
  }

  @override
  void dispose() {
    _controller.removeListener(tabListener);
    super.dispose();
  }

  void tabListener() {
    setState(() {
      selectedIndex = _controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '코팩 딜리버리',
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _controller,
        children: [
          Container(child: RestaurantScreen()),
          Container(child: Text('음식')),
          Container(child: Text('주문')),
          Container(child: Text('프로필')),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.shifting,
        onTap: (int index) {
          _controller.animateTo(index);
        },
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fastfood_outlined), label: '음식'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined), label: '주문'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: '프로필'),
        ],
      ),
    );
  }
}
