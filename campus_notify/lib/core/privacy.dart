final _email = RegExp(r'[\w.+-]+@[\w-]+\.[\w.]+');
final _longNumber = RegExp(r'\d{8,}');

/// Removes emails and long digit runs (phone, ID numbers) before text
/// leaves the device.
String redactSensitive(String input) =>
    input.replaceAll(_email, '[email]').replaceAll(_longNumber, '[number]');
