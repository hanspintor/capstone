import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 150,
                  child: DrawerHeader(
                      child: Icon(Icons.account_circle_rounded, size: 80,),
                    decoration: BoxDecoration(
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.place, color: Color(0xfffb0d0d),),
                  title: Text('Pin Location', style: TextStyle(color: Color(0xfffb0d0d))),
                  onTap: () {
                    selectedItem(context, 0);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bookmark, color: Color(0xfffb0d0d),),
                  title: Text('Courier Bookmarks', style: TextStyle(color: Color(0xfffb0d0d))),
                  onTap: () {
                    selectedItem(context, 1);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notification_important_rounded, color: Color(0xfffb0d0d),),
                  title: Text('Delivery Status', style: TextStyle(color: Color(0xfffb0d0d))),
                  onTap: () {
                  },
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping_rounded, color: Color(0xfffb0d0d),),
                  title: Text('Search Courier', style: TextStyle(color: Color(0xfffb0d0d))),
                  onTap: () {
                    selectedItem(context, 3);
                  },
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 20,
            width: MediaQuery.of(context).size.width / 1,
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout_rounded),
              label: Text('Logout'),
              onPressed: (){
              },
              style: ElevatedButton.styleFrom(primary: Color(0xfffb0d0d), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),),
            ),
          ),
        ],
      ),
    );
  }
  void selectedItem(BuildContext context, int index){
    Navigator.of(context).pop();
    switch (index){
      case 0:
        Navigator.pushNamed(context, '/dashboardLocation');
        break;
      case 1:
        Navigator.pushNamed(context, '/courierBookmarks');
        break;
      case 2:
        Navigator.pop(context);
        break;
      case 3:
        Navigator.pushNamed(context, '/dashboardCustomer');
        break;
    }
  }

}
