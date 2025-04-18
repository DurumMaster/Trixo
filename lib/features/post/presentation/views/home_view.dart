import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   // Listener para detectar cuando el usuario está cerca del final del scroll
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels >=
  //             _scrollController.position.maxScrollExtent - 200 &&
  //         !ref.read(postsProvider).isLoading &&
  //         !ref.read(postsProvider).isLastPage) {
  //       ref.read(postsProvider.notifier).loadNextPage();
  //     }
  //   });
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home View'),
      ),
    );
  }
}
