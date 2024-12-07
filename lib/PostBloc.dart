import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DatabaseHelper.dart';
import 'Post.dart';
import 'PostEvent.dart';
import 'PostState.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final DatabaseHelper databaseHelper;
  final http.Client httpClient;

  PostBloc({required this.databaseHelper, required this.httpClient}) : super(PostInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
  }

  Future<void> _onFetchPosts(FetchPostsEvent event, Emitter<PostState> emit) async {
    try {
      emit(PostLoading());
      print("Attempting to fetch posts from the database...");
      List<Map<String, dynamic>> cachedPosts = await databaseHelper.getPosts();
      if (cachedPosts.isNotEmpty) {
        print("Posts found in database: $cachedPosts");
        emit(PostLoaded(posts: cachedPosts.map((e) => Post.fromJson(e)).toList()));
        return;
      }

      print("No posts in database, fetching from API...");
      final response = await httpClient.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
      print("API Response Status Code: ${response.statusCode}");
      print("API Response Body: ${response.body}");
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Post> posts = data.map((json) => Post.fromJson(json)).toList();
        databaseHelper.insertPosts(posts.map((e) => e.toJson()).toList());
        emit(PostLoaded(posts: posts));

      } else {
        emit(PostError(message: 'Failed to load posts'));
      }
    } catch (e) {
      emit(PostError(message: e.toString()));
    }
  }
}


