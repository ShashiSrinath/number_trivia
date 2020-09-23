import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:number_trivia/core/error/failures.dart';

class InputConverter extends Equatable {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    final value = int.tryParse(str);

    if (value == null || value < 0) {
      return Left(InvalidInputFailure());
    } else {
      return Right(value);
    }
  }

  @override
  List<Object> get props => [];
}

class InvalidInputFailure extends Failure {
  @override
  List<Object> get props => [];
}
