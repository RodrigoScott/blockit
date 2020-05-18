class CodeModel {
  String name;
  String code;
  int id;

  CodeModel.init();

  CodeModel({this.name, this.code, this.id});

  factory CodeModel.fromJson(Map<String, dynamic> json) {
    return CodeModel(
        name: json["padlock_name"], code: json["code"], id: json['local_id']);
  }
  Map<String, dynamic> toJson() =>
      {"padlock_name": name, "code": code, 'local_id': id};
}
