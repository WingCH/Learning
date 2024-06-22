import 'package:equatable/equatable.dart';

class Optional<T> extends Equatable {
  final T raw;

  const Optional(this.raw);

  @override
  List<Object?> get props => [raw];
  static const Optional<Null> empty = Optional(null);
}
