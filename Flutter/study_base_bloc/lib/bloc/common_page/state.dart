part of 'bloc.dart';

abstract class CommonPageState extends Equatable {
  final bool isLoading;

  const CommonPageState({this.isLoading = false});

  CommonPageState copyWith({
    bool? isLoading,
  });
}
