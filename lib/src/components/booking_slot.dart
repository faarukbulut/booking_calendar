import 'package:booking_calendar/src/components/common_card.dart';
import 'package:flutter/material.dart';

class BookingSlot extends StatelessWidget {
  const BookingSlot({
    Key? key,
    required this.child,
    required this.isBooked,
    required this.onTap,
    required this.isSelected,
    required this.isPauseTime,
    this.hideBreakSlot,
    required this.slotDate,
  }) : super(key: key);

  final Widget child;
  final bool isBooked;
  final bool isPauseTime;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? hideBreakSlot;
  final DateTime slotDate;

  Color getSlotColor() {
    if (isPauseTime) {
      return Colors.grey;
    }
    if (isBooked) {
      return Colors.red;
    } 
    if(isSelected){
      return Colors.indigo;
    }
    else{
      if(slotDate.minute == 0 || slotDate.minute == 30){
        return Colors.green; // Tam saatler yeşil.
      }
      else{
        return Colors.green.shade300;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (hideBreakSlot != null && hideBreakSlot == true && isPauseTime)
        ? const SizedBox()
        : GestureDetector(
            onTap: (!isBooked && !isPauseTime) ? onTap : null,
            child: CommonCard(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                color: getSlotColor(),
                child: child),
          );
  }
}
