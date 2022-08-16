import 'package:flutter/material.dart';
import 'package:photos/ente_theme_data.dart';
import 'package:photos/models/search/holiday_search_result.dart';
import 'package:photos/ui/viewer/search/search_result_widgets/search_result_thumbnail_widget.dart';

class HolidaySearchResultWidget extends StatelessWidget {
  static const String _tagPrefix = "holiday_search";

  final HolidaySearchResult holidaySearchResult;
  const HolidaySearchResultWidget(this.holidaySearchResult, {Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final noOfMemories = holidaySearchResult.files.length;
    final heroTagPrefix = _tagPrefix + holidaySearchResult.holidayName;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Theme.of(context).colorScheme.searchResultsColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SearchResultThumbnailWidget(
                holidaySearchResult.files[0],
                heroTagPrefix,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.subTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    holidaySearchResult.holidayName,
                    style: const TextStyle(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .searchResultsCountTextColor,
                      ),
                      children: [
                        TextSpan(text: noOfMemories.toString()),
                        TextSpan(
                          text: noOfMemories != 1 ? ' memories' : ' memory',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.subTextColor,
              ),
            ],
          ),
        ),
      ),
      onTap: () {},
    );
  }
}
