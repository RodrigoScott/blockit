class VersionAppModel {
  String version;

  VersionAppModel.init();

  VersionAppModel({
    this.version,
  });

  factory VersionAppModel.fromJson(Map<String, dynamic> json) {
    return VersionAppModel(
      version: json['version'],
    );
  }
  Map toJson() => {
        "version": this.version,
      };
}
