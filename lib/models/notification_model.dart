/// notification : [{"consumer_blast_id":"121","consumer_blast_title":"Halo Food Delivery📣","consumer_blast_content":"Anda kreatif, anda menang RM500 setiap minggu.#haloje","blast_created_datetime":"2021-05-04 09:42:04","blast_scheduled_datetime":"2021-05-04 15:00:00","blast_start_datetime":"2021-05-04 15:00:01","blast_complete_datetime":"2021-05-04 15:02:11","blast_by":"chong","blast_success":"45183","blast_failure":"12884","consumer_blast_status":"active","consumer_blast_display_status":"show"},{"consumer_blast_id":"120","consumer_blast_title":"Halo Food Delivery📣","consumer_blast_content":"Jom sertai kempen #haloje untuk menang RM500 setiap minggu","blast_created_datetime":"2021-05-04 09:41:08","blast_scheduled_datetime":"2021-05-04 10:00:00","blast_start_datetime":"2021-05-04 10:00:04","blast_complete_datetime":"2021-05-04 10:02:13","blast_by":"chong","blast_success":"45150","blast_failure":"12840","consumer_blast_status":"active","consumer_blast_display_status":"show"}]

class NotificationModel {
  List<NotificationSingleModel> _notification;

  List<NotificationSingleModel> get notification => _notification;

  set notification(List<NotificationSingleModel> value) {
    _notification = value;
  }

  NotificationModel({
      List<NotificationSingleModel> notification}){
    _notification = notification;
}

  NotificationModel.fromJson(dynamic json) {
    if (json['notification'] != null) {
      _notification = [];
      json['notification'].forEach((v) {
        _notification.add(NotificationSingleModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_notification != null) {
      map['notification'] = _notification.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// consumer_blast_id : "121"
/// consumer_blast_title : "Halo Food Delivery📣"
/// consumer_blast_content : "Anda kreatif, anda menang RM500 setiap minggu.#haloje"
/// blast_created_datetime : "2021-05-04 09:42:04"
/// blast_scheduled_datetime : "2021-05-04 15:00:00"
/// blast_start_datetime : "2021-05-04 15:00:01"
/// blast_complete_datetime : "2021-05-04 15:02:11"
/// blast_by : "chong"
/// blast_success : "45183"
/// blast_failure : "12884"
/// consumer_blast_status : "active"
/// consumer_blast_display_status : "show"

class NotificationSingleModel {
  String _consumerBlastId;
  String _consumerBlastTitle;
  String _consumerBlastContent;
  String _blastCreatedDatetime;
  String _blastScheduledDatetime;
  String _blastStartDatetime;
  String _blastCompleteDatetime;
  String _blastBy;
  String _blastSuccess;
  String _blastFailure;
  String _consumerBlastStatus;
  String _consumerBlastDisplayStatus;

  String get consumerBlastId => _consumerBlastId;
  String get consumerBlastTitle => _consumerBlastTitle;
  String get consumerBlastContent => _consumerBlastContent;
  String get blastCreatedDatetime => _blastCreatedDatetime;
  String get blastScheduledDatetime => _blastScheduledDatetime;
  String get blastStartDatetime => _blastStartDatetime;
  String get blastCompleteDatetime => _blastCompleteDatetime;
  String get blastBy => _blastBy;
  String get blastSuccess => _blastSuccess;
  String get blastFailure => _blastFailure;
  String get consumerBlastStatus => _consumerBlastStatus;
  String get consumerBlastDisplayStatus => _consumerBlastDisplayStatus;

  NotificationSingleModel({
      String consumerBlastId, 
      String consumerBlastTitle, 
      String consumerBlastContent, 
      String blastCreatedDatetime, 
      String blastScheduledDatetime, 
      String blastStartDatetime, 
      String blastCompleteDatetime, 
      String blastBy, 
      String blastSuccess, 
      String blastFailure, 
      String consumerBlastStatus, 
      String consumerBlastDisplayStatus}){
    _consumerBlastId = consumerBlastId;
    _consumerBlastTitle = consumerBlastTitle;
    _consumerBlastContent = consumerBlastContent;
    _blastCreatedDatetime = blastCreatedDatetime;
    _blastScheduledDatetime = blastScheduledDatetime;
    _blastStartDatetime = blastStartDatetime;
    _blastCompleteDatetime = blastCompleteDatetime;
    _blastBy = blastBy;
    _blastSuccess = blastSuccess;
    _blastFailure = blastFailure;
    _consumerBlastStatus = consumerBlastStatus;
    _consumerBlastDisplayStatus = consumerBlastDisplayStatus;
}

  NotificationSingleModel.fromJson(dynamic json) {
    _consumerBlastId = json['consumer_blast_id'];
    _consumerBlastTitle = json['consumer_blast_title'];
    _consumerBlastContent = json['consumer_blast_content'];
    _blastCreatedDatetime = json['blast_created_datetime'];
    _blastScheduledDatetime = json['blast_scheduled_datetime'];
    _blastStartDatetime = json['blast_start_datetime'];
    _blastCompleteDatetime = json['blast_complete_datetime'];
    _blastBy = json['blast_by'];
    _blastSuccess = json['blast_success'];
    _blastFailure = json['blast_failure'];
    _consumerBlastStatus = json['consumer_blast_status'];
    _consumerBlastDisplayStatus = json['consumer_blast_display_status'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['consumer_blast_id'] = _consumerBlastId;
    map['consumer_blast_title'] = _consumerBlastTitle;
    map['consumer_blast_content'] = _consumerBlastContent;
    map['blast_created_datetime'] = _blastCreatedDatetime;
    map['blast_scheduled_datetime'] = _blastScheduledDatetime;
    map['blast_start_datetime'] = _blastStartDatetime;
    map['blast_complete_datetime'] = _blastCompleteDatetime;
    map['blast_by'] = _blastBy;
    map['blast_success'] = _blastSuccess;
    map['blast_failure'] = _blastFailure;
    map['consumer_blast_status'] = _consumerBlastStatus;
    map['consumer_blast_display_status'] = _consumerBlastDisplayStatus;
    return map;
  }

}