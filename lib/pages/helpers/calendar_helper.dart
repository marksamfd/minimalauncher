import 'package:device_calendar/device_calendar.dart';
import 'package:minimalauncher/pages/right_screen.dart';

class CalendarHelper {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<List<Event>> fetchCalendarEvents() async {
    List<Event> events = [];

    // Request permissions
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return [];
      }
    }

    // Retrieve calendars
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {
      final calendars = calendarsResult.data!;
      
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final endDate = DateTime.now().add(const Duration(days: 90));

      for (var calendar in calendars) {
        if (calendar.isReadOnly == true) continue; // Optional: skip read-only if desired, but usually we want to read them
        
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate),
        );

        if (eventsResult.isSuccess && eventsResult.data != null) {
          for (var deviceEvent in eventsResult.data!) {
            events.add(Event(
              name: deviceEvent.title ?? 'No Title',
              description: deviceEvent.description ?? '',
              deadline: deviceEvent.start != null 
                ? DateTime.fromMillisecondsSinceEpoch(deviceEvent.start!.millisecondsSinceEpoch)
                : DateTime.now(),
              showOnHomeScreen: true, // Default to true for calendar events?
              isCompleted: false,
            ));
          }
        }
      }
    }

    return events;
  }
}
