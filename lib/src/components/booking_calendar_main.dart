import 'package:booking_calendar/src/components/booking_dialog.dart';
import 'package:booking_calendar/src/components/booking_explanation.dart';
import 'package:booking_calendar/src/components/booking_slot.dart';
import 'package:booking_calendar/src/components/common_button.dart';
import 'package:booking_calendar/src/components/common_card.dart';
import 'package:booking_calendar/src/core/booking_controller.dart';
import 'package:booking_calendar/src/model/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:booking_calendar/src/util/booking_util.dart';

class BookingCalendarMain extends StatefulWidget {
  const BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.uploadBooking,
    this.bookingExplanation,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonText,
    this.bookingButtonColor,
  }) : super(key: key);

  final Stream<dynamic>? Function({required DateTime start, required DateTime end}) getBookingStream;
  final Future<dynamic> Function({required BookingService newBooking}) uploadBooking;
  final List<DateTimeRange> Function({required dynamic streamResult}) convertStreamResultToDateTimeRanges;

  final Widget? bookingExplanation;
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final String? bookingButtonText;
  final Color? bookingButtonColor;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  late BookingController controller;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();

    startOfDay = now.startOfDay;
    endOfDay = now.endOfDay;
    _focusedDay = now;
    _selectedDay = now;
  }

  CalendarFormat _calendarFormat = CalendarFormat.twoWeeks;

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDay;
    endOfDay = _selectedDay.add(const Duration(days: 1)).endOfDay;

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: (controller.isUploading)
          ? const BookingDialog()
          : Column(
              children: [
                CommonCard(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 1000)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    calendarStyle: const CalendarStyle(isTodayHighlighted: true),
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        selectNewDateRange();
                      }
                    },
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                widget.bookingExplanation ??
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        BookingExplanation(color: Colors.greenAccent, text: "Available"),
                        BookingExplanation(color: Colors.orangeAccent, text: "Selected"),
                        BookingExplanation(color: Colors.redAccent, text: "Booked"),
                      ],
                    ),
                const SizedBox(height: 8),
                StreamBuilder<dynamic>(
                  stream: widget.getBookingStream(start: startOfDay, end: endOfDay),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    ///this snapshot should be converted to List<DateTimeRange>
                    final data = snapshot.requireData;
                    controller.generateBookedSlots(widget.convertStreamResultToDateTimeRanges(streamResult: data));

                    return Expanded(
                      child: GridView.builder(
                        itemCount: controller.allBookingSlots.length,
                        itemBuilder: (context, index) => BookingSlot(
                          isBooked: controller.isSlotBooked(index),
                          isSelected: index == controller.selectedSlot,
                          onTap: () => controller.selectSlot(index),
                          child: Center(
                            child: Text(
                              widget.formatDateTime?.call(controller.allBookingSlots.elementAt(index)) ??
                                  BookingUtil.formatDateTime(controller.allBookingSlots.elementAt(index)),
                            ),
                          ),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widget.bookingGridCrossAxisCount ?? 3,
                          childAspectRatio: widget.bookingGridChildAspectRatio ?? 1.5,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                CommonButton(
                  text: widget.bookingButtonText ?? 'BOOK',
                  onTap: () async {
                    controller.toggleUploading();
                    await widget.uploadBooking(newBooking: controller.generateNewBookingForUploading());
                    controller.toggleUploading();
                    controller.resetSelectedSlot();
                  },
                  isDisabled: controller.selectedSlot == -1,
                  buttonActiveColor: widget.bookingButtonColor,
                ),
              ],
            ),
    );
  }
}