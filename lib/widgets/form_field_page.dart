import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';

import '../entities_place_picker/entities.dart';

class FormWidget extends StatefulWidget {
  const FormWidget({
    Key? key,
    required this.initString,
    required this.showArrow,
    this.bottomWidget,
    required this.localizationItem,
    this.searchTopText,
    this.searchTopTextStyle,
    required this.showTip,
    required this.tipText,
    this.colorTip,
    // required this.isNeedToUseGeocoding,
    // this.userCanOnlyPickState,
    // required this.geocoderProvider,
    // required this.userAgentPackageName,
    this.formattedAddressSuggestions,
    this.citySuggestions,
    this.streetSuggestions,
    this.streetNumberSuggestions,
    this.countrySuggestions,
    this.administrativeArea1Suggestions,
    required this.formFieldParams,
  });

  /// First text that will be autofilled in search field
  final String initString;
  final bool showArrow;
  final Widget? bottomWidget;
  final LocalizationItem localizationItem;

  final Future<List<String>> Function(String)? formattedAddressSuggestions;
  final Future<List<String>> Function(String)? citySuggestions;
  final Future<List<String>> Function(String)? streetSuggestions;
  final Future<List<String>> Function(String)? streetNumberSuggestions;
  final Future<List<String>> Function(String)? countrySuggestions;
  final Future<List<String>> Function(String)? administrativeArea1Suggestions;

  final FormFieldParams formFieldParams;

  /// It can only be single line height
  final String? searchTopText;
  final TextStyle? searchTopTextStyle;

  /// Bottom container with text tip
  final bool showTip;
  final String tipText;

  /// Color of bottom tip
  final Color? colorTip;

  /// If `true` map after selecting place after tap on search item will use additinal request
  /// to geocode location
  // final bool isNeedToUseGeocoding;

  /// If not `null` user can't choose other state exept [userCanOnlyPickState]
  // final String? userCanOnlyPickState;

  /// Used to geocode location name
  // final GeocoderProvider geocoderProvider;

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class FormFieldParams {
  final bool showFormattedAddressField;
  final bool showCountryField;
  final bool showAdministrativeAreaLevel1;
  final bool showCityField;
  final bool showStreetField;
  final bool showStreetNumberField;
  final InputBorder borderFields;

  const FormFieldParams({
    this.showFormattedAddressField = false,
    this.showCountryField = false,
    this.showAdministrativeAreaLevel1 = false,
    this.showStreetField = true,
    this.showCityField = true,
    this.showStreetNumberField = true,
    this.borderFields = const OutlineInputBorder(),
  });
}

class _FormWidgetState extends State<FormWidget> {
  LocationResult locationResult = LocationResult();

  @override
  Widget build(BuildContext context) {
    final params = widget.formFieldParams;
    final formLocalizationItem = widget.localizationItem.formLocalizationItem;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          icon: Icon(Icons.close_rounded),
        ),
        actions: [
          if (widget.showArrow)
            IconButton(
              onPressed: () => validateForm(context),
              icon: Icon(Icons.arrow_forward),
            )
        ],
      ),
      bottomNavigationBar: Container(
        child: ElevatedButton(
            onPressed: () => validateForm(context),
            child: Text(widget.localizationItem.submit)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.searchTopText != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.searchTopText!),
                ),
              if (params.showFormattedAddressField)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                    label: Text(formLocalizationItem.formattedAddress),
                  ),
                  asyncSuggestions: widget.formattedAddressSuggestions ??
                      loadEmptySuggestions,
                  onChanged: (v) {
                    locationResult =
                        locationResult.copyWith(formattedAddress: v);
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              if (params.showCountryField)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                      label: Text(formLocalizationItem.country),
                      border: params.borderFields),
                  asyncSuggestions:
                      widget.countrySuggestions ?? loadEmptySuggestions,
                  onChanged: (value) {
                    locationResult = locationResult.copyWith(
                        country:
                            AddressComponent(name: value, shortName: value));
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              if (params.showAdministrativeAreaLevel1)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                      label:
                          Text(formLocalizationItem.administrativeAreaLevel1)),
                  asyncSuggestions: widget.administrativeArea1Suggestions ??
                      loadEmptySuggestions,
                  onChanged: (value) {
                    locationResult = locationResult.copyWith(
                      administrativeAreaLevel1:
                          AddressComponent(name: value, shortName: value),
                    );
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              if (params.showCityField)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration:
                      InputDecoration(label: Text(formLocalizationItem.city)),
                  asyncSuggestions:
                      widget.citySuggestions ?? loadEmptySuggestions,
                  onChanged: (value) {
                    locationResult = locationResult.copyWith(
                        city: AddressComponent(name: value, shortName: value));
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              if (params.showStreetField)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration:
                      InputDecoration(label: Text(formLocalizationItem.street)),
                  asyncSuggestions:
                      widget.streetSuggestions ?? loadEmptySuggestions,
                  onChanged: (value) {
                    locationResult = locationResult.copyWith(name: value);
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              if (params.showStreetNumberField)
                EasyAutocomplete(
                  progressIndicatorBuilder: CircularProgressIndicator(),
                  keyboardType: TextInputType.streetAddress,
                  decoration: InputDecoration(
                      label: Text(formLocalizationItem.streetNumber)),
                  asyncSuggestions:
                      widget.streetNumberSuggestions ?? loadEmptySuggestions,
                  onChanged: (value) {
                    locationResult =
                        locationResult.copyWith(streetNumber: value);
                  },
                  onSubmitted: (v) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              const SizedBox(height: 16),
              if (widget.showTip)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: widget.colorTip ?? const Color(0xFF6dc2ff),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Text(widget.tipText,
                      style: const TextStyle(color: Colors.white)),
                ),
              const SizedBox(height: 24),
              if (widget.bottomWidget != null) widget.bottomWidget!
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> loadEmptySuggestions(String query) async {
    return [];
  }

  void validateForm(BuildContext context) {
    Navigator.of(context).pop(locationResult);
  }
}
