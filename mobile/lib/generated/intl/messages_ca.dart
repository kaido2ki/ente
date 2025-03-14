// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ca locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ca';

  static String m1(count) => "\$photoCount photos";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "allWillShiftRangeBasedOnFirst": MessageLookupByLibrary.simpleMessage(
            "This is the first in the group. Other selected photos will automatically shift based on this new date"),
        "editTime": MessageLookupByLibrary.simpleMessage("Edit time"),
        "moveSelectedPhotosToOneDate": MessageLookupByLibrary.simpleMessage(
            "Move selected photos to one date"),
        "newRange": MessageLookupByLibrary.simpleMessage("New range"),
        "photocountPhotos": m1,
        "photosKeepRelativeTimeDifference":
            MessageLookupByLibrary.simpleMessage(
                "Photos keep relative time difference"),
        "previous": MessageLookupByLibrary.simpleMessage("Previous"),
        "selectDate": MessageLookupByLibrary.simpleMessage("Select date"),
        "selectOneDateAndTime":
            MessageLookupByLibrary.simpleMessage("Select one date and time"),
        "selectOneDateAndTimeForAll": MessageLookupByLibrary.simpleMessage(
            "Select one date and time for all"),
        "selectStartOfRange":
            MessageLookupByLibrary.simpleMessage("Select start of range"),
        "selectTime": MessageLookupByLibrary.simpleMessage("Select time"),
        "shiftDatesAndTime":
            MessageLookupByLibrary.simpleMessage("Shift dates and time"),
        "thisWillMakeTheDateAndTimeOfAllSelected":
            MessageLookupByLibrary.simpleMessage(
                "This will make the date and time of all selected photos the same.")
      };
}
