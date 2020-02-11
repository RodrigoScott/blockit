class Location {

  String latitude;
  String longitude;
  String code;
  String name;
  bool inside;

  Location.init();

  Location({
    this.latitude,
    this.longitude,
    this.code,
    this.name,
    this.inside,
    });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      inside:  json['inside'],
      code: json['code'],
    );}

  Map toJson() => {
    "lat": this.latitude,
    "lng": this.longitude,
    "padlock_name": this.name,
  };
}
