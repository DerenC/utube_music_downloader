import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/snackbar_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// const _primaryColor = Color(0xFFFAA76C);
// const _primaryColor = Color(0xFFFA937C);
const _primaryColor = Color(0xFFF98289);
// const _primaryColor = Color(0xFFF97D8E);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Utube Music Downloader',
      theme: ThemeData(
        brightness: Brightness.dark, // This ensures it's a dark theme
        primaryColor: _primaryColor, // Primary color for foreground elements
        scaffoldBackgroundColor:
            const Color(0xFF1F1A32), // Dark blue background color
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1A32), // Dark blue app bar
          foregroundColor: _primaryColor, // Amber icons/text in app bar
        ),
        textTheme: const TextTheme(
          bodyLarge:
              TextStyle(color: Colors.white), // General text color is white
          bodyMedium:
              TextStyle(color: Colors.white), // General text color is white
          titleLarge: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold), // Headings amber
        ),
        iconTheme:
            const IconThemeData(color: _primaryColor), // Icon color is amber
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primaryColor, // FAB background color
          foregroundColor: Color(0xFF1F1A32), // FAB icon/text color (dark blue)
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(_primaryColor),
            foregroundColor: MaterialStateProperty.all(const Color(0xFF1F1A32)),
          ),
        ),
      ),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.lightBlue,
      //   ),
      // ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final _directoryPathController = TextEditingController(
    text: 'Music/utube_music_downloader',
  );
  final _fileNameController = TextEditingController();
  final _textFieldFocusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  String _youtubeUrl = '';
  bool _isTopButtonLoading = false;
  bool _isBottomButtonLoading = false;

  Future<void> _downloadMusic() async {
    for (var focusNode in _textFieldFocusNodes) {
      focusNode.unfocus();
    }
    setState(() {
      _isTopButtonLoading = true;
    });
    var ytExplode = YoutubeExplode();

    String url;
    if (_youtubeUrl.contains('v=')) {
      url = _youtubeUrl.split('v=')[1];
      url = url.split('&')[0];
    } else if (_youtubeUrl.contains('youtu.be/')) {
      url = _youtubeUrl.split('youtu.be/')[1];
      url = url.split('?')[0];
    } else {
      throw Exception('Invalid URL');
    }
    var video = await ytExplode.videos.get(_youtubeUrl);
    debugPrint(video.title);

    var manifest = await ytExplode.videos.streams.getManifest(url);

    debugPrint(manifest.toString());

    var streamInfo = manifest.audioOnly.first;
    var audioStream = ytExplode.videos.streamsClient.get(streamInfo);

    Directory? directory;
    File? file;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // public Music folder - android only - API > 30
        directory =
            Directory('/storage/emulated/0/${_directoryPathController.text}');
      } else {
        directory = await getExternalStorageDirectory();
        if (directory == null) {
          if (defaultTargetPlatform == TargetPlatform.android) {
            if (await _requestPermission(Permission.storage)) {
              directory = await getExternalStorageDirectory();
            }
          } else {
            if (await _requestPermission(Permission.photos)) {
              directory = await getExternalStorageDirectory();
            }
          }
        }
        directory ??= await getApplicationDocumentsDirectory();
        directory =
            Directory('${directory.path}/${_directoryPathController.text}');
      }

      debugPrint('Currently in directory: ${directory.path}');

      bool hasExisted = await directory.exists();
      if (!hasExisted) {
        directory.create();
      }

      // File to saved
      if (_fileNameController.text.isEmpty) {
        _fileNameController.text = video.title;
      }
      final savePath = '${directory.path}/${_fileNameController.text}.mp3';
      file = File(savePath);

      debugPrint('File to be saved: $savePath');

      bool fileHasExisted = await file.exists();
      if (!fileHasExisted) {
        await file.create();
      }

      var fileStream = file.openWrite();
      await audioStream.pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();
      debugPrint('Downloaded to $savePath');
    } catch (e) {
      if (file != null && file.existsSync()) {
        file.deleteSync();
      }

      rethrow;
    } finally {
      setState(() {
        _isTopButtonLoading = false;
      });
      ytExplode.close();
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  Future<String> _getYoutubeTitle(String url) async {
    setState(() {
      _isBottomButtonLoading = true;
    });
    if (url.isEmpty) {
      throw Exception('URL is empty');
    }

    var ytExplode = YoutubeExplode();
    var video = await ytExplode.videos.get(url);
    return video.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Download any YouTube video \n as MP3 song',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: TextField(
                focusNode: _textFieldFocusNodes[0],
                onChanged: (value) {
                  _youtubeUrl = value;
                },
                decoration: InputDecoration(
                  labelText: 'Enter URL',
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                focusNode: _textFieldFocusNodes[1],
                controller: _directoryPathController,
                decoration: InputDecoration(
                  labelText: 'Download directory path',
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextField(
                focusNode: _textFieldFocusNodes[2],
                controller: _fileNameController,
                decoration: InputDecoration(
                  labelText: 'File Name',
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: 180,
              child: ElevatedButton(
                onPressed: () {
                  _getYoutubeTitle(_youtubeUrl).then((value) {
                    _fileNameController.text = value;
                    showSuccessSnackbar(context, 'Retrieve title successfully');
                    setState(() {
                      _isBottomButtonLoading = false;
                    });
                  }).catchError((e) {
                    setState(() {
                      _isBottomButtonLoading = false;
                    });
                    debugPrint('Error: $e');
                    showErrorSnackbar(
                        context, 'Failed to get title: ${e.message}');
                  });
                },
                child: _isBottomButtonLoading
                    ? SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(),
                      )
                    : Text('Get title from URL'),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: 180,
              child: ElevatedButton(
                onPressed: _isTopButtonLoading
                    ? null
                    : () => _downloadMusic().then(
                          (_) {
                            showSuccessSnackbar(context,
                                'Downloaded "${_fileNameController.text}" successfully');
                          },
                        ).catchError(
                          (e) {
                            setState(() {
                              _isTopButtonLoading = false;
                            });
                            debugPrint('Error: $e');
                            showErrorSnackbar(context,
                                'Failed to download: ${e.message == 'Cannot create file' ? 'File already exists' : e.message}');
                          },
                        ),
                child: _isTopButtonLoading
                    ? SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(),
                      )
                    : Text('Download the song'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
