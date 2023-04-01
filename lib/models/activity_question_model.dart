/// questions : [{"problem":"Makanan lambat sampai?","problemToSend":"Makanan lambat sampai?"},{"problem":"Makanan belum sampai masa?","problemToSend":"Makanan belum sampai masa?"},{"problem":"Makanan kurang atau salah?","problemToSend":"Makanan kurang atau salah?"},{"problem":"Rider lambat accept order?","problemToSend":"Rider lambat accept order?"},{"problem":"Order pending?","problemToSend":"Order pending?"},{"problem":"Waiting payment?","problemToSend":"Waiting payment?"},{"problem":"Cancel order?","problemToSend":"Cancel order?"},{"problem":"Tukar payment?","problemToSend":"Tukar payment?"},{"problem":"Alamat Salah?","problemToSend":"Alamat Salah?"}]

class ActivityQuestionModel {
  List<Questions> _questions;

  List<Questions> get questions => _questions;

  set questions(List<Questions> value) {
    _questions = value;
  }

  ActivityQuestionModel({
      List<Questions> questions}){
    _questions = questions;
}

  ActivityQuestionModel.fromJson(dynamic json) {
    if (json['questions'] != null) {
      _questions = [];
      json['questions'].forEach((v) {
        _questions.add(Questions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_questions != null) {
      map['questions'] = _questions.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// problem : "Makanan lambat sampai?"
/// problemToSend : "Makanan lambat sampai?"

class Questions {
  String _problem;
  String _problemToSend;

  String get problem => _problem;
  String get problemToSend => _problemToSend;

  Questions({
      String problem, 
      String problemToSend}){
    _problem = problem;
    _problemToSend = problemToSend;
}

  Questions.fromJson(dynamic json) {
    _problem = json['problem'];
    _problemToSend = json['problemToSend'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['problem'] = _problem;
    map['problemToSend'] = _problemToSend;
    return map;
  }

}