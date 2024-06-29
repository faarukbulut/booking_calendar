import 'package:flutter/material.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  initializeDateFormatting()
      .then((_) => runApp(const BookingCalendarDemoApp()));
}

class BookingCalendarDemoApp extends StatefulWidget {
  const BookingCalendarDemoApp({Key? key}) : super(key: key);

  @override
  State<BookingCalendarDemoApp> createState() => _BookingCalendarDemoAppState();
}

class _BookingCalendarDemoAppState extends State<BookingCalendarDemoApp> {
  final now = DateTime.now();
  late BookingService mockBookingService;

  int selectedRadio = 5;

  @override
  void initState() {
    super.initState();
    mockBookingService = BookingService(
      serviceName: 'Mock Service',
      serviceDuration: 10,
      bookingStart: DateTime(now.year, now.month, now.day, 1, 0),
      bookingEnd: DateTime(now.year, now.month, now.day, 23, 10),
    );
  }

  Stream<dynamic>? getBookingStreamMock(
      {required DateTime end, required DateTime start}) {
    return Stream.value([]);
  }

  Future<dynamic> uploadBookingMock(
      {required BookingService newBooking}) async {
    await Future.delayed(const Duration(seconds: 1));
    converted.add(DateTimeRange(
        start: newBooking.bookingStart, end: newBooking.bookingEnd));
    print('${newBooking.toJson()} has been uploaded');
  }

  List<DateTimeRange> converted = [];

  List<DateTimeRange> convertStreamResultMock({required dynamic streamResult}) {
    ///here you can parse the streamresult and convert to [List<DateTimeRange>]
    ///take care this is only mock, so if you add today as disabledDays it will still be visible on the first load
    ///disabledDays will properly work with real data
    DateTime first = now;
    DateTime tomorrow = now.add(const Duration(days: 1));
    DateTime second = now.add(const Duration(minutes: 55));
    DateTime third = now.subtract(const Duration(minutes: 240));
    DateTime fourth = now.subtract(const Duration(minutes: 500));
    converted.add(
        DateTimeRange(start: first, end: now.add(const Duration(minutes: 30))));
    converted.add(DateTimeRange(
        start: second, end: second.add(const Duration(minutes: 23))));
    converted.add(DateTimeRange(
        start: third, end: third.add(const Duration(minutes: 15))));
    converted.add(DateTimeRange(
        start: fourth, end: fourth.add(const Duration(minutes: 50))));

    //book whole day example
    converted.add(DateTimeRange(
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 5, 0),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 0)));
    return converted;
  }

  iptalRandevu(){
    print('iptal clicked');
  }

  guncelleRandevu(dynamic value){
    print('guncelle clicked : ${value.bookingStart}, $selectedRadio');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Booking Calendar Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Booking Calendar Demo'),
          ),
          body: SizedBox(
            width: 1135,
            height: MediaQuery.of(context).size.height / 1.8,
            child: BookingCalendar(
              bookingService: mockBookingService,
              convertStreamResultToDateTimeRanges: convertStreamResultMock,
              getBookingStream: getBookingStreamMock,
              uploadBooking: uploadBookingMock,
              randevuGuncelle: (val){guncelleRandevu(val);},
              randevuIptal: iptalRandevu,
              selectedRadio: selectedRadio,
              radioOnChanged: (val){},
              pauseSlotText: 'LUNCH',
              hideBreakTime: false,
              loadingWidget: const Text('Fetching data...'),
              uploadingWidget: const CircularProgressIndicator(),
              startingDayOfWeek: StartingDayOfWeek.tuesday,
              wholeDayIsBookedWidget: const Text('Sorry, for this day everything is booked'),
              bookingGridCrossAxisCount: 6,
              randevuIptalButtonColor: Colors.red,
            ),
          ),
        ));
  }
}
