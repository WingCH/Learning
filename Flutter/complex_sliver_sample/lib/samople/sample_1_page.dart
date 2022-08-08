import 'package:flutter/material.dart';

class Sample1Page extends StatefulWidget {
  const Sample1Page({Key? key}) : super(key: key);

  @override
  State<Sample1Page> createState() => _Sample1PageState();
}

class _Sample1PageState extends State<Sample1Page>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                color: Colors.red,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.yellow,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MySliverPersistentHeaderDelegate(),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          viewportFraction: 0.5,
          children: const <Widget>[
            DemoListView(key: Key('listView1')),
            DemoListView(key: Key('listView2')),
          ],
        ),
      ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: Colors.blue,
        alignment: Alignment.center,
        child: const Text('我是一個SliverPersistentHeader',
            style: TextStyle(color: Colors.white)));
  }

  @override
  double get maxExtent => 100.0;

  @override
  double get minExtent => 100.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}

class DemoListView extends StatefulWidget {
  const DemoListView({Key? key}) : super(key: key);

  @override
  State<DemoListView> createState() => _DemoListViewState();
}

class _DemoListViewState extends State<DemoListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: widget.key,
      prototypeItem: const ListTile(title: Text("1")),
      //itemExtent: 56,
      itemBuilder: (context, index) {
        return ListTile(title: Text("$index"));
      },
    );
  }
}
