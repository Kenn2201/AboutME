
class Images{
  static const String asset = 'assets/';
  static const frontLogo1 = '${asset}aboutmelogin1.png';
  static const frontLogo2 = '${asset}mobilesign.png';
}

class UserData {


  final String name;
  final String contact;
  final String age;
  final String birthdate;
  final String address;
  final String hobbies;

  UserData({
    required this.name,
    required this.contact,
    required this.age,
    required this.birthdate,
    required this.address,
    required this.hobbies,
  });

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      name: map['name'],
      age: map['age'],
      contact: map['contact'],
      birthdate: map['birthdate'],
      address: map['address'],
      hobbies: map['hobbies'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contact': contact,
      'age': age,
      'birthdate': birthdate,
      'address': address,
      'hobbies': hobbies,
    };
  }


}









