import 'failures.dart';

String formatDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

String messageOf(Object e) =>
    e is Failure ? e.message : e.toString().replaceFirst('Exception: ', '');
