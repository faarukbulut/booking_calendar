import 'package:booking_calendar/src/components/common_modal.dart';
import 'package:booking_calendar/src/components/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:table_calendar/table_calendar.dart' as tc show StartingDayOfWeek;

import '../core/booking_controller.dart';
import '../model/enums.dart' as bc;
import '../util/booking_util.dart';
import 'booking_dialog.dart';
import 'booking_slot.dart';
import 'common_button.dart';
import 'common_card.dart';

// ignore: must_be_immutable
class BookingCalendarMain extends StatefulWidget {
  BookingCalendarMain({
    Key? key,
    required this.getBookingStream,
    required this.convertStreamResultToDateTimeRanges,
    required this.randevuIptal,
    required this.randevuGuncelle,
    required this.selectedRadio,
    required this.radioOnChanged,
    required this.uyelerList,
    this.bookingGridCrossAxisCount,
    this.bookingGridChildAspectRatio,
    this.formatDateTime,
    this.bookingButtonColor,
    this.randevuIptalButtonColor,
    this.bookedSlotTextStyle,
    this.selectedSlotTextStyle,
    this.availableSlotTextStyle,
    this.gridScrollPhysics,
    this.loadingWidget,
    this.errorWidget,
    this.uploadingWidget,
    this.wholeDayIsBookedWidget,
    this.pauseSlotText,
    this.hideBreakTime = false,
    this.startingDayOfWeek,
    this.disabledDays,
    this.disabledDates,
    this.lastDay,
  }) : super(key: key);

  final Stream<dynamic>? Function({required DateTime start, required DateTime end}) getBookingStream;
  final Function randevuIptal;
  final Function randevuGuncelle;
  final List<DateTimeRange> Function({required dynamic streamResult}) convertStreamResultToDateTimeRanges;

  ///Customizable
  final int? bookingGridCrossAxisCount;
  final double? bookingGridChildAspectRatio;
  final String Function(DateTime dt)? formatDateTime;
  final Color? bookingButtonColor;
  final Color? randevuIptalButtonColor;

//Added optional TextStyle to available, booked and selected cards.
  final String? pauseSlotText;

  final TextStyle? bookedSlotTextStyle;
  final TextStyle? availableSlotTextStyle;
  final TextStyle? selectedSlotTextStyle;

  final ScrollPhysics? gridScrollPhysics;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? uploadingWidget;

  final bool? hideBreakTime;
  final DateTime? lastDay;
  final bc.StartingDayOfWeek? startingDayOfWeek;
  final List<int>? disabledDays;
  final List<DateTime>? disabledDates;

  final Widget? wholeDayIsBookedWidget;

  // Update Custom
  late int selectedRadio;
  final ValueChanged<int> radioOnChanged;
  final List uyelerList;

  @override
  State<BookingCalendarMain> createState() => _BookingCalendarMainState();
}

class _BookingCalendarMainState extends State<BookingCalendarMain> {
  late BookingController controller;
  final now = DateTime.now();
  List selectedUyelerValues = [];
  String uyeler = "";

  @override
  void initState() {
    super.initState();
    controller = context.read<BookingController>();
    final firstDay = calculateFirstDay();

    startOfDay = firstDay.startOfDayService(controller.serviceOpening!);
    endOfDay = firstDay.endOfDayService(controller.serviceClosing!);
    _focusedDay = firstDay;
    _selectedDay = firstDay;
    controller.selectFirstDayByHoliday(startOfDay, endOfDay);
  }

  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime startOfDay;
  late DateTime endOfDay;

  void selectNewDateRange() {
    startOfDay = _selectedDay.startOfDayService(controller.serviceOpening!);
    endOfDay = _selectedDay
        .add(const Duration(days: 1))
        .endOfDayService(controller.serviceClosing!);

    controller.base = startOfDay;
    controller.resetSelectedSlot();
  }

  DateTime calculateFirstDay() {
    final now = DateTime.now();
    if (widget.disabledDays != null) {
      return widget.disabledDays!.contains(now.weekday)
          ? now.add(Duration(days: getFirstMissingDay(now.weekday)))
          : now;
    } else {
      return DateTime.now();
    }
  }

  int getFirstMissingDay(int now) {
    for (var i = 1; i <= 7; i++) {
      if (!widget.disabledDays!.contains(now + i)) {
        return i;
      }
    }
    return -1;
  }

  void openSelectUyelerDialog() {
    CommonModal.buildMultiSelectDialogField(
      context: context,
      label: "Randevu Üyeleri",
      itemList: widget.uyelerList,
      multipleSelectedValues: selectedUyelerValues,
      onMultipleItemsChange: (item) {
        setState(() {
          uyeler = "";
          selectedUyelerValues = item;
          item.map((e) => {uyeler = '$uyeler, ${e.adi}'}).toList();
          uyeler = uyeler.substring(1);
        });

        print(selectedUyelerValues.length);
        print(uyeler);
      },
      itemBuilder: (BuildContext context, item, bool isSelected) {
        return Container(
          decoration: !isSelected
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
          child: ListTile(
            trailing: isSelected ? const Icon(Icons.check) : null,
            selected: isSelected,
            title: Text(
              item.adi,
              style: TextStyle(
                fontSize: 18,
                color: isSelected ? Colors.indigo : Colors.black87,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    controller = context.watch<BookingController>();

    return Consumer<BookingController>(
      builder: (_, controller, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: (controller.isUploading)
            ? widget.uploadingWidget ?? const BookingDialog()
            : Row(
                children: [
                  Expanded(
                    child: CommonCard(
                      child: TableCalendar(
                        locale: 'tr_TR',
                        startingDayOfWeek: widget.startingDayOfWeek?.toTC() ?? tc.StartingDayOfWeek.monday,
                        holidayPredicate: (day) {
                          if (widget.disabledDates == null) return false;
                    
                          bool isHoliday = false;
                          for (var holiday in widget.disabledDates!) {
                            if (isSameDay(day, holiday)) {
                              isHoliday = true;
                            }
                          }
                          return isHoliday;
                        },
                        enabledDayPredicate: (day) {
                          if (widget.disabledDays == null && widget.disabledDates == null) return true;
                    
                          bool isEnabled = true;
                          if (widget.disabledDates != null) {
                            for (var holiday in widget.disabledDates!) {
                              if (isSameDay(day, holiday)) {
                                isEnabled = false;
                              }
                            }
                            if (!isEnabled) return false;
                          }
                          if (widget.disabledDays != null) {
                            isEnabled =
                                !widget.disabledDays!.contains(day.weekday);
                          }
                    
                          return isEnabled;
                        },
                        firstDay: calculateFirstDay(),
                        lastDay: widget.lastDay ?? DateTime.now().add(const Duration(days: 1000)),
                        focusedDay: _focusedDay,
                        calendarFormat: CalendarFormat.month,
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
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        availableCalendarFormats: const {CalendarFormat.month: "Ay"},
                      ),
                    ),
                  ),

                  const SizedBox(width: 5),

                  Expanded(
                    child: Column(
                      children: [

                        TextFormField(
                          readOnly: true,
                          onTap: () {
                            openSelectUyelerDialog();
                          },
                          //initialValue: uyeler,
                          // controller: TextEditingController()..text = uyeler,
                          enabled: true,
                          keyboardType: TextInputType.name,
                          autofocus: true,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          decoration: CommonTextField.buildCustomFormDecoration(label: "Randevu Üyeleri"),
                        ),

                        StreamBuilder<dynamic>(
                          stream: widget.getBookingStream(start: startOfDay, end: endOfDay),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return widget.errorWidget ?? Center(child: Text(snapshot.error.toString()),);
                            }
                    
                            if (!snapshot.hasData) {
                              return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
                            }
                    
                            ///this snapshot should be converted to List<DateTimeRange>
                            final data = snapshot.requireData;
                            controller.generateBookedSlots(widget.convertStreamResultToDateTimeRanges(streamResult: data));
                    
                            return Expanded(
                              child: (widget.wholeDayIsBookedWidget != null && controller.isWholeDayBooked())
                                ? widget.wholeDayIsBookedWidget!
                                : GridView.builder(
                                    physics: widget.gridScrollPhysics ?? const BouncingScrollPhysics(),
                                    itemCount: controller.allBookingSlots.length,
                                    itemBuilder: (context, index) {
                                      TextStyle? getTextStyle() {
                                        if (controller.isSlotBooked(index)) {
                                          return widget.bookedSlotTextStyle;
                                        } else if (index == controller.selectedSlot) {
                                          return widget.selectedSlotTextStyle;
                                        } else {
                                          return widget.availableSlotTextStyle;
                                        }
                                      }
                    
                                      final slot = controller.allBookingSlots.elementAt(index);
                                      return BookingSlot(
                                          hideBreakSlot: widget.hideBreakTime,
                                          isPauseTime: controller.isSlotInPauseTime(slot),
                                          isBooked: controller.isSlotBooked(index),
                                          isSelected: index == controller.selectedSlot,
                                          onTap: () => controller.selectSlot(index),
                                          slotDate: slot,
                                          child: Center(
                                            child: Text(
                                              widget.formatDateTime?.call(slot) ?? BookingUtil.formatDateTime(slot),
                                              style: getTextStyle(),
                                            ),
                                          ),
                                        );
                                    },
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: widget.bookingGridCrossAxisCount ?? 3,
                                      childAspectRatio: widget.bookingGridChildAspectRatio ?? 1.5,
                                    ),
                                  ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Radio(
                                value: 5,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('5 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 10,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('10 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 15,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('15 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 30,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('30 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 45,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('45 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 60,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('60 Dk'),
                              const SizedBox(width: 10,),
                              Radio(
                                value: 0,
                                groupValue: widget.selectedRadio,
                                onChanged: (val){
                                  setState(() {
                                    widget.selectedRadio = val as int;
                                    widget.radioOnChanged(val);
                                  });
                                },
                              ),
                              const Text('Tüm Gün'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton(
                                text: 'Randevu Ata',
                                onTap: () async {
                                  widget.randevuGuncelle(controller.generateNewBookingForUploading());
                                },
                                isDisabled: controller.selectedSlot == -1,
                                buttonActiveColor: widget.bookingButtonColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CommonButton(
                                text: 'Randevu İptal',
                                onTap: () async {
                                  widget.randevuIptal();
                                },
                                buttonActiveColor: widget.randevuIptalButtonColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
      ),
    );
  }
}

