import 'package:camera_deep_ar/camera_deep_ar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'config.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // CameraDeepArControllerX cameraDeepArController;
  // Effects currentEffect = Effects.none;
  // Filters currentFilter = Filters.none;
  // Masks currentMask = Masks.empty;


  final deepArController = CameraDeepArController(config);
  String _platformVersion = 'Unknown';
  bool isRecording = false;
  CameraMode cameraMode = config.cameraMode;
  DisplayMode displayMode = config.displayMode;
  int currentEffect = 0;

  List get effectList {
    switch (cameraMode) {
      case CameraMode.mask:
        return masks;
      case CameraMode.effect:
        return effects;

      case CameraMode.filter:
        return filters;
      default:
        return masks;
    }
  }

  List masks = [
    "none",
    "assets/aviators",
    "assets/bigmouth",
    "assets/lion",
    "assets/dalmatian",
    "assets/bcgseg",
    "assets/look2",
    "assets/fatify",
    "assets/flowers",
    "assets/grumpycat",
    "assets/koala",
    "assets/mudmask",
    "assets/obama",
    "assets/pug",
    "assets/slash",
    "assets/sleepingmask",
    "assets/smallface",
    "assets/teddycigar",
    "assets/tripleface",
    "assets/twistedface",
  ];
  List effects = [
    "none",
    "assets/fire",
    "assets/heart",
    "assets/blizzard",
    "assets/rain",
  ];
  List filters = [
    "none",
    "assets/drawingmanga",
    "assets/sepia",
    "assets/bleachbypass",
    "assets/realvhs",
    "assets/filmcolorperfection"
  ];

  @override
  void initState() {
    super.initState();
    CameraDeepArController.checkPermissions();
    deepArController.setEventHandler(DeepArEventHandler(onCameraReady: (v) {
      _platformVersion = "onCameraReady $v";
      setState(() {});
    }, onSnapPhotoCompleted: (v) {
      _platformVersion = "onSnapPhotoCompleted $v";
      setState(() {});
    }, onVideoRecordingComplete: (v) {
      _platformVersion = "onVideoRecordingComplete $v";
      setState(() {});
    }, onSwitchEffect: (v) {
      _platformVersion = "onSwitchEffect $v";
      setState(() {});
    }));
  }

  @override
  void dispose() {
    deepArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('DeepAR Camera Example'),
        ),
        body: Stack(
          children: [
            DeepArPreview(deepArController),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(20),
                //height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Response >>> : $_platformVersion\n',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              if (isRecording) return;
                              deepArController.snapPhoto();
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.green
                            ),
                            child: const Icon(Icons.camera_enhance_outlined),
                          ),
                        ),
                        if (displayMode == DisplayMode.image)
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                String path = "assets/testImage.png";
                                final file = await deepArController
                                    .createFileFromAsset(path, "test");

                                // final file = await ImagePicker()
                                //     .pickImage(source: ImageSource.gallery);
                                await Future.delayed(const Duration(seconds: 1));

                                deepArController.changeImage(file.path);
                                if (kDebugMode) {
                                  print("DAMON - Calling Change Image Flutter");
                                }
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green
                              ),
                              child: const Icon(Icons.image),
                            ),
                          ),
                        if (isRecording)
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                deepArController.stopVideoRecording();
                                isRecording = false;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.green
                              ),
                              child: const Icon(Icons.videocam_off),
                            ),
                          )
                        else
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                deepArController.startVideoRecording();
                                isRecording = true;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green
                              ),
                              child: const Icon(Icons.videocam),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(15),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(effectList.length, (p) {
                          bool active = currentEffect == p;
                          String imgPath = effectList[p];
                          return GestureDetector(
                            onTap: () async {
                              if (!deepArController.value.isInitialized) return;
                              currentEffect = p;
                              deepArController.switchEffect(
                                  cameraMode, imgPath);
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              width: active ? 70 : 55,
                              height: active ? 70 : 55,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: active ? Colors.orange : Colors.white,
                                  border: Border.all(
                                      color:
                                      active ? Colors.orange : Colors.white,
                                      width: active ? 2 : 0),
                                  shape: BoxShape.circle),
                              child: Text(
                                "$p",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color:
                                    active ? Colors.white : Colors.black),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: List.generate(CameraMode.values.length, (p) {
                        CameraMode mode = CameraMode.values[p];
                        bool active = cameraMode == mode;

                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.all(2),
                            child: TextButton(
                              onPressed: () async {
                                cameraMode = mode;
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black, backgroundColor: Colors.black,
                                // shape: CircleBorder(
                                //     side: BorderSide(
                                //         color: Colors.white, width: 3))
                              ),
                              child: Text(
                                describeEnum(mode),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color: Colors.white
                                        .withOpacity(active ? 1 : 0.6)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: List.generate(DisplayMode.values.length, (p) {
                        DisplayMode mode = DisplayMode.values[p];
                        bool active = displayMode == mode;

                        return Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.all(2),
                            child: TextButton(
                              onPressed: () async {
                                displayMode = mode;
                                await deepArController.setDisplayMode(
                                    mode: mode);
                                setState(() {});
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.black, backgroundColor: Colors.purple,
                                // shape: CircleBorder(
                                //     side: BorderSide(
                                //         color: Colors.white, width: 3))
                              ),
                              child: Text(
                                describeEnum(mode),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: active ? FontWeight.bold : null,
                                    fontSize: active ? 16 : 14,
                                    color: Colors.white
                                        .withOpacity(active ? 1 : 0.6)),
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}