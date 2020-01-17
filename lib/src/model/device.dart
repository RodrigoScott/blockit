class Device {
  String name;
  String datetime;
  String status;
  int duration;

  Device.init();

  Device({
    this.name,
    this.datetime,
    this.status,
    this.duration,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      name: json['name'],
      datetime: json['datetime'],
      status: json['status'],
      duration: json['duration'],
    );
  }
  Map toJson() => {
        "name": this.name,
        "datetime": this.datetime,
        "status": this.status,
        "duration": this.duration,
      };
}
