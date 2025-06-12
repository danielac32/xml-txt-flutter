

class ListDir {
  Res? res;

  ListDir({this.res});

  ListDir.fromJson(Map<String, dynamic> json) {
    res = json['res'] != null ? Res.fromJson(json['res']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (res != null) {
      data['res'] = res!.toJson();
    }
    return data;
  }
}

class Res {
  int? size;
  List<String>? files;

  Res({this.size, this.files});

  Res.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    files = json['files'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['size'] = size;
    data['files'] = files;
    return data;
  }
}
