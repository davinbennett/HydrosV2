import 'package:flutter/material.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../core/themes/font_size.dart';
import '../../../core/themes/radius_size.dart';
import '../../../core/themes/spacing_size.dart';
import '../../../infrastructure/google_place/config.dart';

class LocationAutoCompleteWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(Prediction)? onPlaceSelected;
  final EdgeInsets padding;
  final String? Function(String?)? validator;
  final Function(String lat, String lng)? onLatLngSelected;

  const LocationAutoCompleteWidget({
    super.key,
    required this.controller,
    this.onPlaceSelected,
    this.padding = const EdgeInsets.symmetric(vertical: 8), 
    this.onLatLngSelected,
    this.validator,
  });

  @override
  State<LocationAutoCompleteWidget> createState() =>
      _LocationAutoCompleteWidgetState();
}

class _LocationAutoCompleteWidgetState
    extends State<LocationAutoCompleteWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GooglePlaceAutoCompleteTextField(
            validator: widget.validator == null ? null : (String? value, BuildContext _ctx) => widget.validator!(value),
            boxDecoration: BoxDecoration(),
            textStyle: TextStyle(
              fontSize: AppFontSize.s
            ),
            textEditingController: widget.controller,
            focusNode: _focusNode,
            googleAPIKey: apiKeyPlace ?? '',
            debounceTime: 400,
            countries: const ["id"],
            isLatLngRequired: true,
            inputDecoration: InputDecoration(
              label: Text('Set Location*'),
              labelStyle: TextStyle(
                color: AppColors.grayLight,
                fontSize: AppFontSize.m,
              ),
              floatingLabelStyle: TextStyle(color: AppColors.orange),
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.rm),
                borderSide: BorderSide(width: 0.7, color: AppColors.grayLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.rm),
                borderSide: BorderSide(width: 1.5, color: AppColors.orange),
              ),
              focusColor: AppColors.orange,
              errorStyle: TextStyle(
                color: AppColors.danger,
                fontSize: AppFontSize.s,
              ),
              errorMaxLines: 2,
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.5, color: AppColors.orange),
                borderRadius: BorderRadius.circular(AppRadius.rm),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.rm),
                borderSide: BorderSide(width: 0.7, color: AppColors.grayLight),
              ),
              prefixIcon: const Icon(Icons.pin_drop_outlined),
              prefixIconColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.focused)) {
                  return AppColors.orange;
                }
                return AppColors.grayLight;
              }),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacingSize.m, // padding kiri-kanan teks
                vertical: AppFontSize.m, // padding atas-bawah teks
              ),
            ),
            getPlaceDetailWithLatLng: (prediction) {
              widget.controller.text = prediction.description ?? '';

              if (widget.onLatLngSelected != null &&
                  prediction.lat != null &&
                  prediction.lng != null) {
                widget.onLatLngSelected!(prediction.lat!, prediction.lng!);
              }

              if (widget.onPlaceSelected != null) {
                widget.onPlaceSelected!(prediction);
              }
            },

            itemClick: (Prediction prediction) {
              widget.controller.text = prediction.description ?? '';
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
              if (widget.onPlaceSelected != null) {
                widget.onPlaceSelected!(prediction);
              }
              FocusScope.of(context).unfocus();
            },
            itemBuilder: (context, index, Prediction prediction) {
              return ListTile(
                dense: true,
                leading: const Icon(Icons.location_on, size: 18),
                title: Text(
                  prediction.description ?? "",
                  style: const TextStyle(fontSize: 14),
                ),
              );
            },
            seperatedBuilder: const Divider(height: 1),
            isCrossBtnShown: true,
            placeType: PlaceType.address,
          ),
        ],
      ),
    );
  }
}
