import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ride_sharing/services/maps_service.dart';

class Prediction {
  final String? description;
  final String placeId;
  final String? lat;
  final String? lng;
  const Prediction({this.description, required this.placeId, this.lat, this.lng});
}

/// Place search through the authenticated server proxy.
class ServerPlaceAutoCompleteTextField extends StatefulWidget {
  final TextEditingController textEditingController;
  final InputDecoration inputDecoration;
  final TextStyle? textStyle;
  final int debounceTime;
  final bool isLatLngRequired;
  final ValueChanged<Prediction> getPlaceDetailWithLatLng;
  final ValueChanged<Prediction> itemClick;
  final Widget Function(BuildContext, int, Prediction) itemBuilder;
  final double containerHorizontalPadding;
  final bool isCrossBtnShown;

  const ServerPlaceAutoCompleteTextField({super.key,
    required this.textEditingController, required this.inputDecoration,
    this.textStyle, this.debounceTime = 250, this.isLatLngRequired = true,
    required this.getPlaceDetailWithLatLng, required this.itemClick,
    required this.itemBuilder, this.containerHorizontalPadding = 0,
    this.isCrossBtnShown = false,
  });

  @override
  State<ServerPlaceAutoCompleteTextField> createState() => _SearchState();
}

class _SearchState extends State<ServerPlaceAutoCompleteTextField> {
  final MapsService _maps = MapsService();
  Timer? _debounce;
  int _generation = 0;
  bool _selecting = false;
  List<Prediction> _items = [];

  @override
  void initState() {
    super.initState();
    widget.textEditingController.addListener(_changed);
  }

  void _changed() {
    if (_selecting) return;
    _debounce?.cancel();
    final generation = ++_generation;
    final input = widget.textEditingController.text.trim();
    if (input.length < 2) {
      if (mounted) setState(() => _items = []);
      return;
    }
    _debounce = Timer(Duration(milliseconds: widget.debounceTime), () async {
      try {
        final result = await _maps.autocomplete(input);
        if (!mounted || generation != _generation) return;
        setState(() => _items = result.map((item) => Prediction(
          description: item['description']?.toString(),
          placeId: item['placeId']?.toString() ?? '',
        )).where((item) => item.placeId.isNotEmpty).toList());
      } catch (_) {
        if (mounted && generation == _generation) setState(() => _items = []);
      }
    });
  }

  Future<void> _choose(Prediction item) async {
    _generation++;
    _debounce?.cancel();
    _selecting = true;
    widget.textEditingController.text = item.description ?? '';
    widget.itemClick(item);
    _selecting = false;
    setState(() => _items = []);
    if (!widget.isLatLngRequired) return;
    try {
      final detail = await _maps.placeDetails(item.placeId);
      if (!mounted) return;
      widget.getPlaceDetailWithLatLng(Prediction(
        description: detail['description']?.toString() ?? item.description,
        placeId: item.placeId,
        lat: detail['lat']?.toString(), lng: detail['lng']?.toString(),
      ));
    } catch (_) { /* The caller retains the typed address without coordinates. */ }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.textEditingController.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    TextField(controller: widget.textEditingController,
      decoration: widget.inputDecoration, style: widget.textStyle),
    if (_items.isNotEmpty) Column(children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: ListView.builder(shrinkWrap: true, itemCount: _items.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () => _choose(_items[index]),
            child: widget.itemBuilder(context, index, _items[index]),
          )),
      ),
      const Align(alignment: Alignment.centerRight,
        child: Text('Google Maps', style: TextStyle(fontSize: 11, color: Colors.grey))),
    ]),
  ]);
}
