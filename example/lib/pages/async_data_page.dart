import 'dart:math';
import 'package:flutter/material.dart';
import 'package:novastate/novastate.dart';

class Post {
  final int id;
  final String title;
  final String body;
  final bool isFavorite;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    this.isFavorite = false,
  });

  Post copyWith({
    int? id,
    String? title,
    String? body,
    bool? isFavorite,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'isFavorite': isFavorite,
    };
  }
}

class AsyncPageState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  const AsyncPageState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  AsyncPageState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
    bool clearError = false,
  }) {
    return AsyncPageState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class PostService {
  static final List<Map<String, dynamic>> _fakePosts = [
    {
      'id': 1,
      'title': 'NovaState là gì?',
      'body':
          'NovaState là một package quản lý state nhẹ và hiệu quả cho Flutter, hỗ trợ các tác vụ đồng bộ và bất đồng bộ.',
      'isFavorite': false,
    },
    {
      'id': 2,
      'title': 'Cách sử dụng Store',
      'body':
          'Store là trung tâm của NovaState, nó lưu trữ state và thông báo khi state thay đổi.',
      'isFavorite': false,
    },
    {
      'id': 3,
      'title': 'StateBuilder và StateSelector',
      'body':
          'StateBuilder giúp rebuild UI khi state thay đổi. StateSelector giúp tối ưu hiệu suất bằng cách chỉ rebuild khi phần được chọn thay đổi.',
      'isFavorite': false,
    },
    {
      'id': 4,
      'title': 'Xử lý state lồng nhau',
      'body':
          'NovaState cung cấp NestedStateExtension để làm việc với state phức tạp dạng lồng nhau một cách dễ dàng.',
      'isFavorite': false,
    },
    {
      'id': 5,
      'title': 'Cập nhật state bất đồng bộ',
      'body':
          'Bạn có thể sử dụng phương thức updateAsync để cập nhật state từ nguồn dữ liệu bất đồng bộ.',
      'isFavorite': false,
    },
  ];

  static Future<List<Post>> fetchPosts() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Random().nextDouble() < 0.3) {
      throw Exception('Không thể kết nối đến server');
    }

    return _fakePosts.map((json) => Post.fromJson(json)).toList();
  }

  static Future<Post> updatePost(Post post) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _fakePosts.indexWhere((p) => p['id'] == post.id);
    if (index != -1) {
      _fakePosts[index] = post.toJson();
    }

    return post;
  }
}

class AsyncDataPage extends StatefulWidget {
  const AsyncDataPage({super.key});

  @override
  State<AsyncDataPage> createState() => _AsyncDataPageState();
}

class _AsyncDataPageState extends State<AsyncDataPage> {
  late final Store<AsyncPageState> _store;

  @override
  void initState() {
    super.initState();
    _store = Store<AsyncPageState>(const AsyncPageState());
    _loadData();
  }

  Future<void> _loadData() async {
    print('AsyncDataPage: Loading data...');
    _store.state = _store.state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _store.updateAsync((state) async {
        print('AsyncDataPage: Fetching posts from service...');
        final posts = await PostService.fetchPosts();
        print('AsyncDataPage: Received ${posts.length} posts');
        return state.copyWith(
          posts: posts,
          isLoading: false,
        );
      });
    } catch (e) {
      print('AsyncDataPage: Error occurred: $e');
      _store.state = _store.state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _refreshData() async {
    print('AsyncDataPage: Refreshing data...');
    _store.state = _store.state.copyWith(
      isRefreshing: true,
      clearError: true,
    );

    try {
      print('AsyncDataPage: Fetching fresh posts...');
      final posts = await PostService.fetchPosts();
      print('AsyncDataPage: Received ${posts.length} fresh posts');
      _store.state = _store.state.copyWith(
        posts: posts,
        isRefreshing: false,
      );
    } catch (e) {
      print('AsyncDataPage: Refresh error: $e');
      _store.state = _store.state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _toggleFavorite(Post post) async {
    print('AsyncDataPage: Toggling favorite for post ${post.id}');
    _store.update((state) {
      final updatedPosts = state.posts.map((p) {
        if (p.id == post.id) {
          return p.copyWith(isFavorite: !p.isFavorite);
        }
        return p;
      }).toList();

      return state.copyWith(posts: updatedPosts);
    });

    try {
      print('AsyncDataPage: Sending update to server for post ${post.id}');
      final updatedPost = post.copyWith(isFavorite: !post.isFavorite);
      await PostService.updatePost(updatedPost);
    } catch (e) {
      print('AsyncDataPage: Error updating favorite status: $e');
      _store.update((state) {
        final revertedPosts = state.posts.map((p) {
          if (p.id == post.id) {
            return p.copyWith(isFavorite: post.isFavorite);
          }
          return p;
        }).toList();

        return state.copyWith(
          posts: revertedPosts,
          error: 'Không thể cập nhật trạng thái yêu thích: ${e.toString()}',
        );
      });
    }
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StateProvider<AsyncPageState>(
      store: _store,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dữ liệu bất đồng bộ'),
          actions: [
            StateBuilder<AsyncPageState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state.isLoading || state.isRefreshing
                      ? null
                      : _refreshData,
                );
              },
            ),
          ],
        ),
        body: StateConsumer<AsyncPageState>(
          builder: (context, state, store) {
            if (state.error != null && !state.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đây là lỗi giả định\n(Xác suất 30%)',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Đã xảy ra lỗi: ${state.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state.isLoading && state.posts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải dữ liệu...'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  post.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: post.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () => _toggleFavorite(post),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(post.body),
                          const SizedBox(height: 8),
                          Text(
                            'ID: ${post.id}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
