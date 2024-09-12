part of 'app_bloc.dart';

@immutable
sealed class AppEvent {
  const AppEvent();
}

final class AppUserSubscriptionRequested extends AppEvent{
  const AppUserSubscriptionRequested();
}

final class AppLogoutRequested extends AppEvent{
  const AppLogoutRequested();
}