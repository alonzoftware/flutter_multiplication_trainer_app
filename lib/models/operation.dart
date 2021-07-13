import 'dart:convert';

Operations operationsFromJson(String str) =>
    Operations.fromJson(json.decode(str));

String operationsToJson(Operations data) => json.encode(data.toJson());

class Operations {
  Operations({
    required this.operations,
  });

  List<Operation> operations;

  factory Operations.fromJson(Map<String, dynamic> json) => Operations(
        operations: List<Operation>.from(
            json["Operations"].map((x) => Operation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Operations": List<dynamic>.from(operations.map((x) => x.toJson())),
      };
}

class Operation {
  Operation({
    required this.factor1,
    required this.factor2,
    required this.result,
  });

  int factor1;
  int factor2;
  int result;

  factory Operation.fromJson(Map<String, dynamic> json) => Operation(
        factor1: json["factor1"],
        factor2: json["factor2"],
        result: json["result"],
      );

  Map<String, dynamic> toJson() => {
        "factor1": factor1,
        "factor2": factor2,
        "result": result,
      };
}
// class Operation {
//   late int factor1;
//   late int factor2;
//   late int result;

//   Operation({
//     required this.factor1,
//     required this.factor2,
//     required this.result,
//   });
// }
// To parse this JSON data, do
//
//     final operations = operationsFromJson(jsonString);
