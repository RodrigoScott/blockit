class LocationModel {

  String latitude;
  String longitude;
  String code;
  String name;
  bool inside;

  LocationModel.init();

  LocationModel({
    this.latitude,
    this.longitude,
    this.code,
    this.name,
    this.inside,
    });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      inside:  json['inside'],
      code: json['code'],
    );}

  Map toJson() => {
    "lat": this.latitude,
    "lng": this.longitude,
    "padlock_name": this.name,
  };
}
