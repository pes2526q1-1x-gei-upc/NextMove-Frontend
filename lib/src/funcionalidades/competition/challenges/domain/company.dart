class Company {
  final String name; // name és clau alternativa (unique + not null)
  final String? email;
  final String? url;
  final String? description;
  final String? logo;

  Company({
    required this.name,
    required this.email,
    required this.url,
    this.description,
    this.logo,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String,
      email: json['email'] as String?,
      url: json['url'] as String?,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
    );
  }
}
