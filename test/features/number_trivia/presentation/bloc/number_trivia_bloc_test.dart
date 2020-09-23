import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  _buildInputTriviaBloc() => NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter,
      );

  test('initialState should be empty', () {
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '123';
    final tNumberParsed = 123;
    final tNumberTrivia =
        NumberTrivia(number: tNumberParsed, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(Right(tNumberParsed));

    blocTest(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((realInvocation) async => Right(tNumberTrivia));
          return _buildInputTriviaBloc();
        },
        act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
        });

    blocTest(
      'should call emit [ErrorState] when the input is invalid',
      build: () {
        when(mockInputConverter.stringToUnsignedInteger(tNumberString))
            .thenReturn(Left(InvalidInputFailure()));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [
        ErrorState(message: INVALID_INPUT_FAILURE_MESSAGE),
      ],
    );

    blocTest('should get data from the getConcreteNumber use case',
        build: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((realInvocation) async => Right(tNumberTrivia));
          return _buildInputTriviaBloc();
        },
        act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) {
          verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
        });

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => Right(tNumberTrivia));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(ServerFailure()));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [
        Loading(),
        ErrorState(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with a proper fail error message',
      build: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(CacheFailure()));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForConcreteNumber(tNumberString)),
      expect: [
        Loading(),
        ErrorState(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 123, text: 'test trivia');

    blocTest('should get data from the getRandomNumber use case',
        build: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((realInvocation) async => Right(tNumberTrivia));
          return _buildInputTriviaBloc();
        },
        act: (b) => b.add(GetTriviaForRandomNumber()),
        verify: (_) {
          verify(mockGetRandomNumberTrivia(NoParams()));
        });

    blocTest(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => Right(tNumberTrivia));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForRandomNumber()),
      expect: [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ],
    );

    blocTest(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(ServerFailure()));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForRandomNumber()),
      expect: [
        Loading(),
        ErrorState(message: SERVER_FAILURE_MESSAGE),
      ],
    );

    blocTest(
      'should emit [Loading, Error] with a proper fail error message',
      build: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((realInvocation) async => Left(CacheFailure()));
        return _buildInputTriviaBloc();
      },
      act: (b) => b.add(GetTriviaForRandomNumber()),
      expect: [
        Loading(),
        ErrorState(message: CACHE_FAILURE_MESSAGE),
      ],
    );
  });
}
