class UserProfile {
  final String id;
  final String name;
  final String email;
  final String city;
  final String currency;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.city = 'Bahawalpur',
    this.currency = 'PKR',
  });
}
