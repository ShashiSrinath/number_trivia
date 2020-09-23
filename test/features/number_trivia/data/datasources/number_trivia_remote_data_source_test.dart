import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  void setUpMockHttpClient200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((realInvocation) async => http.Response(
              fixture('trivia.json'),
              200,
            ));
  }

  void setUpMockHttpClient404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((realInvocation) async => http.Response(
              'Something went wrong',
              404,
            ));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
         being the endpoint and with application/json header''', () async {
      setUpMockHttpClient200();
      dataSource.getConcreteNumberTrivia(tNumber);
      verify(mockHttpClient.get('$NUMBERS_API_ROOT/$tNumber',
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClient200();

      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200',
        () async {
      setUpMockHttpClient404();

      final call = dataSource.getConcreteNumberTrivia;
      expect(() => call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a GET request on a URL with number
         being the endpoint and with application/json header''', () async {
      setUpMockHttpClient200();
      dataSource.getRandomNumberTrivia();
      verify(mockHttpClient.get('$NUMBERS_API_ROOT/random',
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response code is 200 (success)',
        () async {
      setUpMockHttpClient200();

      final result = await dataSource.getRandomNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is not 200',
        () async {
      setUpMockHttpClient404();

      final call = dataSource.getRandomNumberTrivia;
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}
