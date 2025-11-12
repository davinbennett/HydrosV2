import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/global/text_form_field.dart';
import 'package:go_router/go_router.dart';
import 'package:google_places_flutter/model/prediction.dart';

import '../../../../core/themes/colors.dart';
import '../../../../core/themes/font_size.dart';
import '../../../../core/themes/font_weight.dart';
import '../../../../core/themes/spacing_size.dart';
import '../../../../core/utils/validator.dart';
import '../../global/button.dart';
import '../google_place.dart';

class AddPlantBottomSheet extends StatefulWidget {
  const AddPlantBottomSheet({super.key});

  @override
  State<AddPlantBottomSheet> createState() => _AddPlantBottomSheetState();
}

class _AddPlantBottomSheetState extends State<AddPlantBottomSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  String? selectedPlace;
  double plantingWeeks = 4;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  bool get isValid => nameController.text.trim().isNotEmpty;

  Future<void> handleAddPlant() async {
    debugPrint('plant: ${nameController.text}');
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    debugPrint('e');

    setState(() => isLoading = true);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacingSize.l,
          right: AppSpacingSize.l,
          bottom:
              MediaQuery.of(
                context,
              ).viewInsets.bottom, // tetap aman saat keyboard muncul
        ),
        child: Column(
          children: [
            // --- Scrollable Form ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Title ---
                      Text(
                        'Add Plant',
                        style: TextStyle(
                          fontWeight: AppFontWeight.semiBold,
                          fontSize: AppFontSize.l,
                        ),
                      ),
                      SizedBox(height: AppSpacingSize.m),
                  
                      // --- Plant Name ---
                      TextFormFieldWidget(
                        controller: nameController,
                        label: 'Plant Name*',
                        onChanged: (_) => setState(() {}),
                        validator: AppValidator.plantNameRequired,
                      ),
                      SizedBox(height: AppSpacingSize.xl),
                  
                      // --- Duration Slider ---
                      Text(
                        'Planting Duration Plan (Week) *',
                        style: TextStyle(
                          fontSize: AppFontSize.s,
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      Slider(
                        value: plantingWeeks,
                        min: 1,
                        max: 60,
                        divisions: 60,
                        label: plantingWeeks.round().toString(),
                        activeColor: AppColors.orange,
                        onChanged:
                            (value) => setState(() => plantingWeeks = value),
                      ),
                      SizedBox(height: AppSpacingSize.m),
                  
                      // 📍 Location Input
                      Text(
                        "Set Location*",
                        style: TextStyle(
                          fontSize: AppFontSize.s,
                          fontWeight: AppFontWeight.medium,
                        ),
                      ),
                      LocationAutoCompleteWidget(
                        controller: locationController,
                        onPlaceSelected: (Prediction p) {
                          setState(() {
                            selectedPlace = p.description;
                          });
                        },
                        validator: AppValidator.locationRequired,
                      ),
                  
                      SizedBox(height: AppSpacingSize.xl),
                    ],
                  ),
                ),
              ),
            ),

            // --- Save Button (Fix di bawah) ---
            SizedBox(
              width: double.infinity,
              child: ButtonWidget(text: 'Save', onPressed: handleAddPlant),
            ),
            SizedBox(height: AppSpacingSize.m),
          ],
        ),
      ),
    );
  }
}
