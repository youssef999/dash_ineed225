import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yemen_services_dashboard/core/theme/colors.dart';
import 'package:yemen_services_dashboard/features/OFFERS2/all_offers_view.dart';
import 'package:yemen_services_dashboard/features/categories/categories_screen.dart';
import 'package:yemen_services_dashboard/features/categories/get_sub_cat.dart';
import 'package:yemen_services_dashboard/features/categories/sub_cat.dart';
import 'package:yemen_services_dashboard/features/city/add_city.dart';
import 'package:yemen_services_dashboard/features/city/add_places.dart';
import 'package:yemen_services_dashboard/features/money/views/request_money.dart';
import 'package:yemen_services_dashboard/features/money/views/trans_view.dart';
import 'package:yemen_services_dashboard/features/notifications/notifications_screen.dart';
import 'package:yemen_services_dashboard/features/offers/offers_screen.dart';
import 'package:yemen_services_dashboard/features/service_providers/service_providers_screen.dart';
import 'package:yemen_services_dashboard/features/users/users_screen.dart';
import 'features/notifications/noti_cat.dart';
import 'features/ques/get_ques.dart';
import 'features/statistics/views/st_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBJrpvuhdd8osxuAZhIWdjgMb-R_6thgAo",
          appId: "1:978854599781:web:9417f6c4b4c16939497a8c",
          messagingSenderId: "978854599781",
          storageBucket: "gs://servicesapp2024.appspot.com",
          projectId: "servicesapp2024"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      textDirection:TextDirection.rtl,
      title: 'I NEED',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.cairoTextTheme(), // Use Cairo font for all text
      ),

      home: const Directionality(
        textDirection: TextDirection.rtl, // Set app direction to RTL
        child: Dashboard(),
      ),
    initialRoute: '/', // Initial route when the app starts
    //
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}
  String cat='';
class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const CategoriesScreen(),
    const AddAdView(),
    const UsersScreen(),
    const ProvidersScreen(),
    const WorkersHome(),
 //  const StatisticsScreen(),
    const AddSubCat(),
    GetSubCat(cat: cat),
    const RequestMoney(),
    const NotificationsScreen(),
   const NotiCat(),
    const GetQues(),
    //const CountryView (),
    const AddCity(),
    const AddPlaces(),
    // const GetPlacesView(),
    // const GetCityView(),
    OffersScreen(),
     const TransView()
   // const SortedOffersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 800;
    return Scaffold(
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: const Text('لوحة التحكم'),
              centerTitle: true,
              backgroundColor: primaryColor,
            ),
      body: Row(
        children: [
          // Drawer on the right side for larger screens
          if (isLargeScreen)
            Expanded(
              flex: 2,
              child: _buildDrawer(), // Keep drawer open on large screens
            ),
          Expanded(
            flex: 8,
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      // EndDrawer for smaller screens
      endDrawer: isLargeScreen ? null : _buildDrawer(),
    );
  }

  // Drawer content
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: primaryColor,
            ),
            child: Center(
              child: Text(
                'قائمة التحكم',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: GoogleFonts.cairo().fontFamily, // Cairo font
                ),
              ),
            ),
          ),
          _buildDrawerItem(Icons.category, 'الاقسام', 0),
           _buildDrawerItem(Icons.category, 'الاقسام الفرعية', 5),
          _buildDrawerItem(Icons.local_offer, 'الاعلانات', 1),
          _buildDrawerItem(Icons.people, 'المستخدمين', 2),
          _buildDrawerItem(Icons.business, 'مقدمين الخدمات', 3),
       //
          _buildDrawerItem(Icons.bar_chart, ' احصائيات', 4),
          _buildDrawerItem(Icons.monetization_on, ' طلبات السحب ', 7),
          _buildDrawerItem(Icons.notifications, 'ارسال اشعارات', 8),
          _buildDrawerItem(Icons.notifications_active_rounded, ' ارسال اشعار لقسم محدد ', 9),
          _buildDrawerItem(Icons.question_answer, 'الاسئلة الشائعة ', 10),
  //_buildDrawerItem(Icons.location_city_outlined, 'البلاد', 11),
          _buildDrawerItem(Icons.location_city_outlined, 'المحافظات', 11),
          _buildDrawerItem(Icons.place_outlined, 'المناطق', 12),
 
        // _buildDrawerItem(Icons.location_city_outlined, ' عرض و تعديل المناطق ', 13),
          // _buildDrawerItem(Icons.location_city_outlined, 'عرض و تعديل المدن ', 14),


          _buildDrawerItem(Icons.local_offer_outlined, 'العروض ', 13),
           _buildDrawerItem(Icons.monetization_on_sharp, ' المعاملات المالية  ', 14),
        ],
      ),
    );
  }

  // Drawer item builder
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? primaryColor : Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: GoogleFonts.cairo().fontFamily, // Cairo font
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}

// Placeholder Screens

class SortedOffersScreen extends StatelessWidget {
  const SortedOffersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'الترتيب بالتاريخ في العروض',
        style: TextStyle(
          fontSize: 24,
          fontFamily: GoogleFonts.cairo().fontFamily, // Cairo font
        ),
      ),
    );
  }
}
