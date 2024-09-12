
import 'package:equatable/equatable.dart';

class User extends Equatable{
  final String email;
  final String id;
  final String name;
  final String photo;

  User({
    required this.email,
    required this.id,
    required this.name,
    required this.photo
  });

  User copyWith({
    required String? email,
    required String? id,
    required String? name,
    required String? photo
  }){
    return User(
      email: email ?? this.email,
      id:   id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo
    );
  }

  @override
  List<Object?> get props => [email, id, name, photo];

  static final User empty = User(email: '', id: '', name: '', photo: '');

}

