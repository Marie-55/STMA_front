import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/navigation/navigation_event.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          color: const Color(0xFFECE5FF),
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, Icons.calendar_month, "Calendar",
                    state.selectedIndex),
                _buildNavItem(
                    context, 1, Icons.list_alt, "Tasks", state.selectedIndex),
                const SizedBox(width: 30),
                _buildNavItem(context, 3, Icons.note_alt_outlined, "Notes",
                    state.selectedIndex),
                _buildNavItem(
                    context, 4, Icons.person, "Profile", state.selectedIndex),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      String label, int selectedIndex) {
    final bool isSelected = index == selectedIndex;

    return InkWell(
      onTap: () {
        context.read<NavigationBloc>().add(NavigateToTab(index));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF5E32E0) : Colors.grey,
              size: 22,
            ),
            if (label != null)
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? const Color(0xFF5E32E0) : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  height: 1.0,
                ),
                overflow: TextOverflow.visible,
              ),
          ],
        ),
      ),
    );
  }
}

