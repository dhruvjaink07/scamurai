import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final String hintText;
  final Function(DateTime) onDateSelected;

  const CustomDatePicker({
    super.key,
    required this.hintText,
    required this.onDateSelected,
  });

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    FocusScope.of(context)
        .requestFocus(FocusNode()); // 🔥 This prevents the keyboard
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate != null
                  ? "${_selectedDate!.toLocal()}".split(' ')[0]
                  : widget.hintText,
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
