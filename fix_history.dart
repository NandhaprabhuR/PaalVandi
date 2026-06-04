import 'dart:io';

void main() {
  var file = File('lib/bulk_orders/views/bulk_orders_history_view.dart');
  var content = file.readAsStringSync();

  // 1. Replace state vars
  content = content.replaceFirst(
    "String _selectedMonth = 'All Months';",
    "DateTime _selectedDate = DateTime.now();\n  final ScrollController _calendarScrollController = ScrollController();"
  );
  
  // 2. Remove _months
  content = content.replaceFirst(RegExp(r'static const List<String> _months = \[[^\]]+\];'), '');

  // 3. Update _applyFilters
  content = content.replaceFirst(
    '''
      // Month filter
      if (_selectedMonth != 'All Months') {
        final monthIdx = _monthIndex(_selectedMonth);
        if (order.deliveryDate == null ||
            order.deliveryDate!.month != monthIdx) {
          return false;
        }
      }''',
    '''
      // Date filter
      if (order.deliveryDate == null ||
          order.deliveryDate!.year != _selectedDate.year ||
          order.deliveryDate!.month != _selectedDate.month ||
          order.deliveryDate!.day != _selectedDate.day) {
        return false;
      }'''
  );

  // 4. Update UI to replace Month Filter Dropdown with a Month picker
  // Actually, wait, let's just remove the Month Filter from the row and add the Calendar Strip above the Filter Bar.
  file.writeAsStringSync(content);
}
