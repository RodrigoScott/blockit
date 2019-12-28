class User {
  String email;
  String password;
  String name;
  String lastName;
  String carrier;

  User.init();

  User(
      {this.email,
      this.password,
      this.name,
      this.lastName,
      this.carrier,});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      carrier: json['carrier'],
      email: json['email'],
      lastName: json['last_name'],
    );
  }
  Map toJson() => {
        "email": this.email,
        "carrier": this.carrier,
        "password": this.password,
        "name": this.name,
        "last_name": this.lastName,
      };
}
