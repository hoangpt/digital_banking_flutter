class User {
  final String id;
  final String email;
  final double balance;

  User({
    required this.id,
    required this.email,
    this.balance = 5000.0, // Default balance for demo
  });
}
