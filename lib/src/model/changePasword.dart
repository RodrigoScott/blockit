class ChangePassword {
  String oldPassword;
  String newPassword;
  String confirmNewPassword;


  ChangePassword.init();

  ChangePassword(
      {this.oldPassword,
        this.newPassword,
        this.confirmNewPassword});

  factory ChangePassword.fromJson(Map<String, dynamic> json) {
    return ChangePassword(
      oldPassword: json['old_password'],
      newPassword: json['new_password'],
      confirmNewPassword: json['new_password_confirmation'],
    );
  }
  Map toJson() => {
    "old_password": this.oldPassword,
    "new_password": this.newPassword,
    "new_password_confirmation": this.confirmNewPassword,
  };
}

