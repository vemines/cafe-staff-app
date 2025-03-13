part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final List<UserEntity> users;

  const UserLoaded({required this.users});

  @override
  List<Object> get props => [users];
}

class UserCreated extends UserState {
  final UserEntity user;

  const UserCreated({required this.user});

  @override
  List<Object> get props => [user];
}

class UserUpdated extends UserState {
  final UserEntity user;

  const UserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}

class UserDeleted extends UserState {}

class UserError extends UserState {
  final Failure failure;

  const UserError({required this.failure});

  @override
  List<Object> get props => [failure];
}
