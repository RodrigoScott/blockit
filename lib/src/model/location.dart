class Location {

  String latitude;
  String longitude;
  String code;

  Location.init();

  Location({
    this.latitude,
    this.longitude,
    this.code,
    });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude:  json['latitude'],
      longitude: json['longitude'],
      code: json['code'],
    );}

  Map toJson() => {
    "latitude": this.latitude,
    "longitude": this.longitude,
    "code": this.code,
  };
}
