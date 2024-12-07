import 'package:blocsqliteholder/DatabaseHelper.dart';
import 'package:blocsqliteholder/Post.dart';
import 'package:blocsqliteholder/PostBloc.dart';
import 'package:blocsqliteholder/PostEvent.dart';
import 'package:blocsqliteholder/PostState.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bloc_test/bloc_test.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PostBloc postBloc;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
  });

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockHttpClient = MockHttpClient();
    postBloc = PostBloc(databaseHelper: mockDatabaseHelper, httpClient: mockHttpClient);
  });

  group('PostBloc', () {
    test('initial state is PostInitial', () {
      expect(postBloc.state, PostInitial());
    });

    blocTest<PostBloc, PostState>(
      'emits PostLoading and PostLoaded when posts are fetched successfully from the API',
      setUp: () {
        when(() => mockDatabaseHelper.getPosts()).thenAnswer((_) async => []);
        when(() => mockHttpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts')))
            .thenAnswer(
              (_) async => http.Response(
            json.encode([
              {'id': 1, 'title': 'Test Post', 'body': 'Test Body'}
            ]),
            200,
          ),
        );
        when(() => mockDatabaseHelper.insertPosts(any())).thenAnswer((_) async => Future.value());
      },

      build: () => postBloc,
      act: (bloc) async {
        print("Triggering FetchPostsEvent...");
        bloc.add(FetchPostsEvent());
      },
      expect: () => [
        PostLoading(),
        PostLoaded(posts: [Post(id: 1, title: 'Test Post', body: 'Test Body')]),
      ],
      wait: Duration(milliseconds: 5000),  // Adjust if necessary
    );
  });
}

