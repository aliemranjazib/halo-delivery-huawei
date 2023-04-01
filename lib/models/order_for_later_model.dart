class OrderForLaterModel {
  OrderForLaterModel._privateConstructor();
  static final OrderForLaterModel _instance = OrderForLaterModel._privateConstructor();

  factory OrderForLaterModel() {
    return _instance;
  }
  String _selectedDate;
  String _selectedTime;
  bool _orderForLater = false;

  void setUserData({
    String selectedDate,
    String selectedTime,
    bool orderForLater,
  }) {
    this._selectedDate = selectedDate;
    this._selectedTime = selectedTime;
    this._orderForLater = orderForLater;
  }

  bool get orderForLater => _orderForLater;

  String get selectedTime => _selectedTime;

  String get selectedDate => _selectedDate;

  void resetOrderForLaterData() {
    this._selectedDate = null;
    this._selectedTime = null;
    this._orderForLater = false;
  }

  set selectedTime(String value) {
    _selectedTime = value;
  }

  set orderForLater(bool value) {
    _orderForLater = value;
  }

  set selectedDate(String value) {
    _selectedDate = value;
  }
}
