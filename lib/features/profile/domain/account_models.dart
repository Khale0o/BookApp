import 'package:bookapp/features/books/domain/book.dart';

class UserProfile {
  const UserProfile({
    this.email,
    this.firstName,
    this.lastName,
    this.gender,
    this.phoneNumber,
    this.imageUrl,
  });

  final String? email;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? phoneNumber;
  final String? imageUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    email: text(json['email']),
    firstName: text(json['firstName']),
    lastName: text(json['lastName']),
    gender: text(json['gender']),
    phoneNumber: text(json['phoneNumber']),
    imageUrl: text(
      json['userImageUrl'] ?? json['imageUrl'] ?? json['userImage'],
    ),
  );

  String get displayName {
    final value = [firstName, lastName].whereType<String>().join(' ').trim();
    return value.isEmpty ? 'Leaf & Loom reader' : value;
  }
}

class UserAddress {
  const UserAddress({
    this.id,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postalCode,
    this.country,
  });

  final int? id;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? postalCode;
  final String? country;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    id: Book.parseInt(json['id']),
    addressLine1: text(json['addressLine1']),
    addressLine2: text(json['addressLine2']),
    city: text(json['city']),
    postalCode: text(json['postalCode']),
    country: text(json['country']),
  );

  Map<String, Object?> toAddJson() => {
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'city': city,
    'postalCode': postalCode,
    'country': country,
  };

  Map<String, Object?> toEditJson() => {'id': id, ...toAddJson()};

  String get oneLine => [
    addressLine1,
    addressLine2,
    city,
    postalCode,
    country,
  ].whereType<String>().join(', ');
}

class OrderLine {
  const OrderLine({this.bookId, this.title, this.quantity, this.price});
  final int? bookId;
  final String? title;
  final int? quantity;
  final double? price;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
    bookId: Book.parseInt(json['bookId']),
    title: text(json['bookTitle'] ?? json['title']),
    quantity: Book.parseInt(json['quantity']),
    price: Book.parseDouble(json['price'] ?? json['bookPrice']),
  );
}

class UserOrder {
  const UserOrder({this.id, this.status, this.date, this.lines = const []});
  final int? id;
  final String? status;
  final DateTime? date;
  final List<OrderLine> lines;

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    final rawLines = json['orderLine'] ?? json['orderLines'] ?? json['items'];
    return UserOrder(
      id: Book.parseInt(json['id'] ?? json['orderId']),
      status: text(json['orderStatus'] ?? json['status']),
      date: DateTime.tryParse(
        text(json['orderDate'] ?? json['createdAt'] ?? json['date']) ?? '',
      ),
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map(
                  (line) => OrderLine.fromJson(Map<String, dynamic>.from(line)),
                )
                .toList(growable: false)
          : const [],
    );
  }

  double? get total {
    if (lines.any((line) => line.price == null || line.quantity == null)) {
      return null;
    }
    return lines.fold(0, (sum, line) => sum! + line.price! * line.quantity!);
  }
}

String? text(Object? value) {
  if (value is! String) return null;
  final result = value.trim();
  return result.isEmpty ? null : result;
}
