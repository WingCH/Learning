import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/*
Gif playback is limited by phone performance, it is recommended to upload 30fps gif images
Check gif Fps tools: Online exif data viewer
Fps = Duration/ Frame Count
 */
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('30fps'),
            SizedBox(
                width: 150,
                child: Image.network(
                    'https://wunkolo.github.io/post/2020/02/buttery-smooth-10fps/images/33.33fps.gif')),
            const Text('50fps'),
            CachedNetworkImage(
                width: 150,
                imageUrl:
                    'https://wunkolo.github.io/post/2020/02/buttery-smooth-10fps/images/50fps.gif'),
            const Text('100fps'),
            CachedNetworkImage(
                width: 150,
                imageUrl:
                    'https://wunkolo.github.io/post/2020/02/buttery-smooth-10fps/images/100fps.gif'),
          ],
        ),
      ),
    );
  }
}
