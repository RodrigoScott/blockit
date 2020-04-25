class LocationModel {
  String latitude;
  String longitude;
  String code;
  String master;
  String name;
  bool inside;

  LocationModel.init();

  LocationModel(
      {this.latitude,
      this.longitude,
      this.code,
      this.name,
      this.inside,
      this.master});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
        inside: json['inside'],
        code: json['code'],
        master: json['master_code']);
  }

  Map toJson() => {
        "lat": this.latitude,
        "lng": this.longitude,
        "padlock_name": this.name,
      };
}
