class IotDeviceModel {
  int id;
  int user_id;
  String name;
  String mastercode;
  int status;

  IotDeviceModel.init();

  IotDeviceModel({
    this.name,
    this.id,
    this.user_id,
    this.mastercode,
    this.status,
  });

  factory IotDeviceModel.fromJson(Map<String, dynamic> json) {
    return IotDeviceModel(
      name: json['name'],
      id: json['id'],
      user_id: json['user_id'],
      mastercode: json['mastercode'],
      status: json['status'],
    );
  }
  Map toJson() => {
        "name": this.name,
        "id": this.id,
        "user_id": this.user_id,
        "mastercode": this.mastercode,
        "status": this.status,
      };
}
