part of 'app_bloc.dart';

enum AppStatus {authenticated, unauthenticated}

@immutable

class AppState extends Equatable{
  AppState({required User user})
    : this._(
    status : user == User.empty
        ? AppStatus.unauthenticated
        : AppStatus.authenticated,
    user : user
  );

  const AppState._({required this.status, required this.user});

  factory AppState.withDefaultUser({required User user}){
      return AppState(user: user);

  }

  final AppStatus status;
  final User user;

  @override
  List<Object?> get props => [status, user];
}
