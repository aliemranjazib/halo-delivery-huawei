import 'package:haloapp/models/vehicle_model.dart';

class Vehicles {
  List<VehicleModel> getVehicles() {
    return [
      VehicleModel(
        id: '1',
        name: 'Motor',
        image: 'images/ic_motorcycle.png',
        description: 'Ideal for groceries, foods, small parcels',
        description2: '(Starting at 2kg)',
      ),
      VehicleModel(
        id: '2',
        name: 'Car',
        image: 'images/ic_car.png',
        description: 'Ideal for medium item/ fragile / during rain',
        description2: '(Starting at 5kg)',
      ),
    ];
  }

  VehicleModel getVehicle(String id) {
    return this.getVehicles().firstWhere((element) => element.id == id);
  }

  String getVehicleImage(String id) {
    if (id == '1') {
      return 'images/ic_motorcycle.png';
    } else if (id == '2') {
      return 'images/ic_car.png';
    } else {
      return '';
    }
  }

  String getVehicleName(String id) {
    if (id == '1') {
      return 'Motor';
    } else if (id == '2') {
      return 'Car';
    } else {
      return '';
    }
  }

  String getVehicleDeliveryItemSize(String id) {
    if (id == '1') {
      return '32cm x 32cm x 44cm';
    } else if (id == '2') {
      return '50cm × 50cm × 50cm';
    } else {
      return '';
    }
  }

  String getVehicleDeliveryMaxWeight(String id) {
    if (id == '1') {
      return '14kg';
    } else if (id == '2') {
      return '40kg';
    } else {
      return '';
    }
  }
}
