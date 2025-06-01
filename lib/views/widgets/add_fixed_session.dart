import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddFixedSession extends StatefulWidget {
  const AddFixedSession({Key? key}) : super(key: key);

  @override
  State<AddFixedSession> createState() => _AddFixedSessionState();
}

class _AddFixedSessionState extends State<AddFixedSession> {
  final TextEditingController _taskNameController = TextEditingController();
  TimeOfDay? _startTime;
  String _selectedDuration = '25 min';
  Set<String> _selectedDays = {};

  final List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<String> durations = ['25 min', '30 min', '45 min', '60 min', '90 min'];

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add To Timetable",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _taskNameController,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickStartTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startTime == null ? 'Start time' : _startTime!.format(context),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDuration,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9E9E),
                  ),
                  items: durations.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDuration = value!);
                  },
                  dropdownColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Day",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: days.map((day) {
                final selected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedDays.remove(day);
                      } else {
                        _selectedDays = {day};
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF5E32E0) : const Color(0xFFF2EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      day,
                      style: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF5E32E0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final title = _taskNameController.text.trim();
                  final startTime = _startTime != null
                      ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                      : null;
                  final duration = _selectedDuration;
                  final day = _selectedDays.isNotEmpty ? days.indexOf(_selectedDays.first) : null;

                  if (title.isEmpty || startTime == null || day == null) {
                    
                    return;
                  }

                  // Prepare data
                  final data = {
                    "title": title,
                    "day_index": day,
                    "duration": double.parse(duration.split(' ')[0]) / 60, // Converts "30 min" to 0.5
                    "start_time": startTime,
                    "user_id": 1, // Uncomment and set actual user ID if needed
                  };

                  try {
                    final response = await http.post(
                      Uri.parse('https://stma-back.onrender.com/api/fixedSession/create'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(data),
                    );

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      if (mounted) {
                        print("created fixed session");
                        Navigator.pop(context, true); // Only pop if widget is still in tree
                      }
                    } else {
                      if (mounted) {
                       print("failed fixed session");
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E32E0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
