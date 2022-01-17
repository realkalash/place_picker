import 'package:flutter/material.dart';

class SelectPlaceAction extends StatelessWidget {
  final String locationName;
  final String latLngString;
  final String choosedPlaceText;
  final String approximatePointInGmapsText;
  final String tipText;
  final bool showTip;
  final bool showChoosedPlaceCoordinates;
  final bool showArrow;
  final VoidCallback onTap;
  final Widget bottomWidget;
  final Widget iconWidget;
  final Color colorTip;
  
  const SelectPlaceAction({
    Key key,
    @required this.locationName,
    @required this.choosedPlaceText,
    @required this.approximatePointInGmapsText,
    @required this.tipText,
    @required this.showTip,
    @required this.onTap,
    @required this.latLngString,
    @required this.showChoosedPlaceCoordinates,
    @required this.showArrow,
    this.bottomWidget,
    this.iconWidget,
    this.colorTip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (showChoosedPlaceCoordinates) ...[
                          Text(choosedPlaceText),
                          const SizedBox(height: 4),
                          Text(latLngString,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ],
                        const SizedBox(height: 4),
                        Text(approximatePointInGmapsText),
                        const SizedBox(height: 4),
                        Text(locationName,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  if(iconWidget != null) iconWidget,
                  if (showArrow)
                    Container(
                      child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          )),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                ],
              ),
              if (showTip)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: colorTip ?? const Color(0xFF6dc2ff),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: Text(tipText,
                      style: const TextStyle(color: Colors.white)),
                ),
              const SizedBox(height: 24),
              if (bottomWidget != null) bottomWidget
            ],
          ),
        ),
      ),
    );
  }
}
