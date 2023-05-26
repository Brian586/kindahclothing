class CustomLocation {
  final String? city;
  final String? country;

  CustomLocation({this.city, this.country});

  factory CustomLocation.fromJson(Map<String, dynamic> map) {
    return CustomLocation(city: map["city"], country: map["country"]);
  }
}
