import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/task.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../services/task_service.dart';

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({Key? key}) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc(TaskService()),
      child: _AddTaskModalContent(),
    );
  }
}

class _AddTaskModalContent extends StatefulWidget {
  @override
  State<_AddTaskModalContent> createState() => _AddTaskModalContentState();
}

class _AddTaskModalContentState extends State<_AddTaskModalContent> {
  final TextEditingController _taskNameController = TextEditingController();
  String? _selectedDate;
  String _selectedDuration = "25 min";
  String _selectedCategory = "Studies";
  String _priority = "Low";

  @override
  void initState() {
    super.initState();
    _selectedDate = "${DateTime.now().day} ${_getMonth(DateTime.now().month)}, ${DateTime.now().year}";
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Add New Task",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                hintText: "Task Name",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = "${picked.day} ${_getMonth(picked.month)}, ${picked.year}";
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: const Color.fromARGB(255, 103, 117, 189), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Deadline",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _selectedDate!,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: InkWell(
              onTap: () {
                _showDurationPicker();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    const Text(
                      "Duration",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _selectedDuration,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            "Category",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCategoryChip("Studies", _selectedCategory == "Studies"),
              const SizedBox(width: 8),
              _buildCategoryChip("Hobbies", _selectedCategory == "Hobbies"),
              const SizedBox(width: 8),
              _buildAddCategoryButton(),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            "Priority",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriorityOption("Low", Colors.green),
          const SizedBox(height: 8),
          _buildPriorityOption("Medium", Colors.orange),
          const SizedBox(height: 8),
          _buildPriorityOption("Important", Colors.red),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Parse the selected date string into DateTime
                final dateParts = _selectedDate!.split(' ');
                final day = int.parse(dateParts[0]);
                final month = _getMonthNumber(dateParts[1].replaceAll(',', ''));
                final year = int.parse(dateParts[2]);
                final deadline = DateTime(year, month, day);

                // Convert duration string to minutes
                int durationMinutes;
                String numericPart = _selectedDuration.replaceAll(RegExp(r'[^0-9]'), '');
                print('Extracted numeric part: $numericPart from $_selectedDuration');
                
                if (_selectedDuration.contains('hour')) {
                    durationMinutes = int.parse(numericPart) * 60;
                } else {
                    durationMinutes = int.parse(numericPart);
                }

                print('Converting duration: ${_selectedDuration} to $durationMinutes minutes');

                final task = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _taskNameController.text,
                  category: _selectedCategory,
                  deadline: deadline,
                  duration: durationMinutes, // Send as minutes (integer)
                  priority: _priority,
                  isScheduled: false,
                  isSynched: false,
                  toReschedule: false,
                  user: "test@gmail.com",
                  status: "To Do",
                );

                print('Creating task with:');
                print('Title: ${task.title}');
                print('Category: ${task.category}');
                print('Deadline: ${task.deadline}');
                print('Duration: ${task.duration} minutes');
                print('Priority: ${task.priority}');

                context.read<TaskBloc>().add(CreateTask(task));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E32E0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Add Task",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECE5FF) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF5E32E0) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF5E32E0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: const [
          Icon(Icons.add, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            "Add",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(String label, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _priority = label;
        });
      },
      child: Row(
        children: [
          Radio(
            value: label,
            groupValue: _priority,
            activeColor: color,
            onChanged: (value) {
              setState(() {
                _priority = value.toString();
              });
            },
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("Select Duration"),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text("15 min"),
                      onTap: () {
                        setState(() {
                          _selectedDuration = "15 min";
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("25 min"),
                      onTap: () {
                        setState(() {
                          _selectedDuration = "25 min";
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("45 min"),
                      onTap: () {
                        setState(() {
                          _selectedDuration = "45 min";
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text("1 hour"),
                      onTap: () {
                        setState(() {
                          _selectedDuration = "1 hour";
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  int _getMonthNumber(String month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months.indexOf(month) + 1;
  }
}