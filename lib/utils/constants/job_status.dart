class JobStatus {
  static const String pending = 'pending';
  static const String otw = 'ontheway';
  static const String otwPickedUp = 'pickedUp';
  static const String delivered = 'delivered';
  static const String canceled = 'canceled';

  String getJobStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'pending';
      case 'new':
        return 'pending';
      case 'accepted':
        return 'accepted';
      case 'ontheway':
        return 'on_the_way_pick_up';
      case 'started':
        return 'picked_up_n_on_the_way_deliver';
      case 'completed':
        return 'completed';
      case 'canceled':
        return 'cancelled';
      default:
        return status;
    }
  }
}
