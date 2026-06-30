import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddressSearchField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Function(String address, double lat, double lng) onSelected;

  const AddressSearchField({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: TextEditingController(),
      googleAPIKey: "AIzaSyBZzeMTeVLRFPXPaMzaCQKHhtFFOhrj2-M",
      inputDecoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor, width: 1.5),
        ),
      ),
      debounceTime: 400,
      countries: ["gh"],
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        final lat = double.tryParse(prediction.lat ?? '0') ?? 0;
        final lng = double.tryParse(prediction.lng ?? '0') ?? 0;
        onSelected(prediction.description ?? '', lat, lng);
      },
      itemClick: (Prediction prediction) {},
    );
  }
}
