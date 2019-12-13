class User {
  String email;
  String password;
  String name;
  String lastName;
  String address;
  String image;

  User.init();

  User(
      {this.email,
      this.password,
      this.name,
      this.lastName,
      this.address,
      this.image});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      image: json['image'],
      address: json['domicilio'],
      email: json['email'],
      lastName: json['last_name'],
    );
  }
  Map toJson() => {
        "email": this.email,
        "domicilio": this.address,
        "password": this.password,
        "name": this.name,
        "last_name": this.lastName,
        "image": this.image
      };
}
