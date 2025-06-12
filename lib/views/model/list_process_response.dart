class ListProcess {
  List<Resultados>? resultados;
  int? totalErrores;
  int? totalPlanillas;

  ListProcess({this.resultados, this.totalErrores, this.totalPlanillas});

  ListProcess.fromJson(Map<String, dynamic> json) {
    if (json['resultados'] != null) {
      resultados = <Resultados>[];
      json['resultados'].forEach((v) {
        resultados!.add(Resultados.fromJson(v));
      });
    }
    totalErrores = json['total_errores'];
    totalPlanillas = json['total_planillas'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (resultados != null) {
      data['resultados'] = resultados!.map((v) => v.toJson()).toList();
    }
    data['total_errores'] = totalErrores;
    data['total_planillas'] = totalPlanillas;
    return data;
  }
}

class Resultados {
  String? archivo;
  int? planillas;
  int? errores;

  Resultados({this.archivo, this.planillas, this.errores});

  Resultados.fromJson(Map<String, dynamic> json) {
    archivo = json['archivo'];
    planillas = json['planillas'];
    errores = json['errores'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['archivo'] = archivo;
    data['planillas'] = planillas;
    data['errores'] = errores;
    return data;
  }
}
