String hideEmail(String email) {
  final parts = email.split('@');
  if (parts.length != 2) return email;
  final username = parts[0];
  if (username.length <= 2) {
    return '${username[0]}****@${parts[1]}';
  }

  final masked =
      '${username[0]}****${username[username.length - 1]}';

  return '$masked@${parts[1]}';
}
