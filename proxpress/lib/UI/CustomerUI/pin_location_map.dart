import 'dart:async';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter/material.dart';

class LocationAppExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LocationAppExampleState();
}

class _LocationAppExampleState extends State<LocationAppExample> {
  ValueNotifier<GeoPoint> notifier = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<GeoPoint>(
              valueListenable: notifier,
              builder: (ctx, p, child) {
                return Center(
                  child: Text(
                    "${p?.toString() ?? ""}",
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var p = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
                    if (p != null) {
                      notifier.value = p as GeoPoint;
                    }
                  },
                  child: Text("pick address"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var p = await showSimplePickerLocation(
                      context: context,
                      isDismissible: true,
                      title: "location picker",
                      textConfirmPicker: "pick",
                      initCurrentUserPosition: false,
                      initZoom: 8,
                      initPosition:
                      GeoPoint(latitude: 13.621980880497976, longitude: 123.19477396693487),
                      radius: 8.0,
                    );
                    if (p != null) {
                      notifier.value = p;
                    }
                  },
                  child: Text("show picker address"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController textEditingController = TextEditingController();
  PickerMapController controller = PickerMapController(
    initMapWithUserPosition: true,
    initPosition: GeoPoint(latitude: 13.621980880497976, longitude: 123.19477396693487),
  );

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(textOnChanged);
  }

  void textOnChanged() {
    controller.setSearchableText(textEditingController.text);
  }

  @override
  void dispose() {
    textEditingController.removeListener(textOnChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPickerLocation(
          controller: controller,
          topWidgetPicker: TopSearchWidget(),
          bottomWidgetPicker: Positioned(
            bottom: 12,
            right: 8,
            child: FloatingActionButton(
              onPressed: () async {
                GeoPoint p = await controller.selectAdvancedPositionPicker();
                Navigator.pop(context, p);
              },
              child: Icon(Icons.location_on_rounded),
            ),
          ),
          initZoom: 17,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(80,30,50,0),
          child: Container(
            height: 50,
            width: 600,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: TextField(
                controller: textEditingController,
                onEditingComplete: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 20,
                  ),
                  suffix: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: textEditingController,
                    builder: (ctx, text, child) {
                      if (text.text.isNotEmpty) {
                        return child;
                      }
                      return SizedBox.shrink();
                    },
                    child: InkWell(
                      focusNode: FocusNode(),
                      onTap: () {
                        textEditingController.clear();
                        controller.setSearchableText("");
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    //gapPadding: 10,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5,27,50,0),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: IconButton(
                icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ),
      ],
    );
  }
}

class TopSearchWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TopSearchWidgetState();
}

class _TopSearchWidgetState extends State<TopSearchWidget> {
  PickerMapController controller;
  ValueNotifier<GeoPoint> notifierGeoPoint = ValueNotifier(null);
  ValueNotifier<bool> notifierAutoCompletion = ValueNotifier(false);

  StreamController<List<SearchInfo>> streamSuggestion = StreamController();
  Future<List<SearchInfo>> _futureSuggestionAddress;
  String oldText = "";
  Timer _timerToStartSuggestionReq;
  final Key streamKey = Key("streamAddressSug");

  @override
  void initState() {
    super.initState();
    controller = CustomPickerLocation.of(context);
    controller.searchableText.addListener(onSearchableTextChanged);
  }

  void onSearchableTextChanged() async {
    final v = controller.searchableText.value;
    if (v.length > 3 && oldText != v) {
      oldText = v;
      if (_timerToStartSuggestionReq != null &&
          _timerToStartSuggestionReq.isActive) {
        _timerToStartSuggestionReq.cancel();
      }
      _timerToStartSuggestionReq =
          Timer.periodic(Duration(seconds: 3), (timer) async {
            await suggestionProcessing(v);
            timer.cancel();
          });
    }
    if (v.isEmpty) {
      await reInitStream();
    }
  }

  Future reInitStream() async {
    notifierAutoCompletion.value = false;
    await streamSuggestion.close();
    setState(() {
      streamSuggestion = StreamController();
    });
  }

  Future<void> suggestionProcessing(String addr) async {
    notifierAutoCompletion.value = true;
    _futureSuggestionAddress = addressSuggestion(
      addr,
      limitInformation: 5,
    );
    _futureSuggestionAddress.then((value) {
      streamSuggestion.sink.add(value);
    });
  }

  @override
  void dispose() {
    controller.searchableText.removeListener(onSearchableTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifierAutoCompletion,
      builder: (ctx, isVisible, child) {
        return AnimatedContainer(
          margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
          duration: Duration(
            milliseconds: 500,
          ),
          height: isVisible ? MediaQuery.of(context).size.height / 4 : 0,
          child: Card(
            child: child
          ),
        );
      },
      child: StreamBuilder<List<SearchInfo>>(
        stream: streamSuggestion.stream,
        key: streamKey,
        builder: (ctx, snap) {
          if (snap.hasData) {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snap.data.length,
              itemBuilder: (ctx, index) {
                print(snap.data[index].address.country);
                return ListTile(
                  title: Text(
                    snap.data[index].address.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                  ),
                  onTap: () async {
                    /// go to location selected by address
                    controller.goToLocation(
                      snap.data[index].point,
                    );

                    /// hide suggestion card
                    notifierAutoCompletion.value = false;
                    await reInitStream();
                    FocusScope.of(context).requestFocus(
                      new FocusNode(),
                    );
                  },
                );
              },
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return Card(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}