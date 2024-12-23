import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:personal_expense_tracker/db/expense/expense_db.dart';
import 'package:personal_expense_tracker/presentation/screens/addExpense.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpenseList extends StatefulWidget {
  const ExpenseList({super.key});

  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {

  DateTime? _startDate;
  DateTime? _endDate;
  String? _sortOrder = 'asc';

  @override
  void initState() {
    ExpenseDB().refreshUI();
    _scheduleDailyReminder();
    super.initState();
  }

  void _filterByDate() async {
    final selectedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (selectedDateRange != null) {
      setState(() {
        _startDate = selectedDateRange.start;
        _endDate = selectedDateRange.end;
      });
      ExpenseDB().refreshUI();
    }
  }

  void _sortExpenses(List<ExpenseModel> expenses) {
    if (_sortOrder == 'asc') {
      expenses.sort((a, b) => a.date.compareTo(b.date));
    } else {
      expenses.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  @override
   Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: _filterByDate,
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                setState(() {
                  _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                  ExpenseDB().refreshUI(); // Refresh UI after sorting
                });
              },
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: ExpenseDB().expenseList,
          builder: (BuildContext context, List<ExpenseModel> expenses, Widget? _) {
            // Apply date filter if any
            if (_startDate != null && _endDate != null) {
              expenses = expenses.where((expense) {
                final expenseDate = DateFormat('yyyy-MM-dd').parse(expense.date);
                return expenseDate.isAfter(_startDate!) && expenseDate.isBefore(_endDate!);
              }).toList();
            }

            // Sort the expenses based on the selected order
            _sortExpenses(expenses);

            return Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  final expense = expenses[index];
                  return Card(
                    elevation: 0,
                    child: ListTile(
                      leading: Text(expense.date),
                      title: Text(expense.amount),
                      subtitle: Text(expense.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => AddExpense(expense: expense),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              ExpenseDB.instance.deleteExpense(expense.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, int index) {
                  return const SizedBox(height: 10);
                },
                itemCount: expenses.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _scheduleDailyReminder() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // Notification ID
    'Reminder', // Title
    'Don\'t forget to record your expenses today!', // Body
    _nextInstanceOfTime(20, 0), // Time: 8:00 PM every day
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_expense_reminder_channel',
        'Daily Expense Reminder',
        channelDescription: 'Daily reminder to record your expenses.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// Get the next instance of the time
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

}
