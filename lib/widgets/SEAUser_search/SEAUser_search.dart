import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/services/helpers.dart';
import 'package:sea/widgets/SEAUser_search/SEAUser_bloc.dart';

import '../../models/SEAUser.dart';

class SEAUserSearch extends ConsumerStatefulWidget {
  final bool? refresh;
  final EdgeInsets? listPadding;
  final EdgeInsets? searchBarPadding;
  final Widget Function(SEAUser, SEAUserNotifier) listTile;
  final Widget? separator;
  final bool Function(SEAUser)? filter;
  final Widget? emptyState;
  const SEAUserSearch({Key? key,
    required this.listTile,
    this.listPadding,
    this.searchBarPadding,
    this.separator,
    this.filter,
    this.refresh,
    this.emptyState,
  }) : super(key: key);

  @override
  ConsumerState<SEAUserSearch> createState() => _SEAUserSearchState();
}

class _SEAUserSearchState extends ConsumerState<SEAUserSearch> {

  final _searchTextController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final SEAUserProvider = ChangeNotifierProvider.autoDispose<SEAUserNotifier>((ref) {
    return SEAUserNotifier();
  });

  void _feedScrollListener() {
    final ap = ref.read(SEAUserProvider);
    if (!ap.isLoading) {
      if (scrollController.offset >= scrollController.positions.last.maxScrollExtent && !scrollController.positions.last.outOfRange) {
        print("reached the bottom");
        ap.setLoading(true);
        ap.getData(mounted, _searchTextController.text.isEmpty ? null : _searchTextController.text, widget.filter);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_feedScrollListener);

    final fp = ref.read(SEAUserProvider);

    if(mounted){
      fp.data.isNotEmpty ? print('data already loaded') :
      fp.getData(mounted, null, widget.filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cb = ref.watch(SEAUserProvider);
    if(widget.refresh ?? false) {
      ref.read(SEAUserProvider).onRefresh(mounted, _searchTextController.text, widget.filter);
    }
    return SingleChildScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: widget.searchBarPadding ?? EdgeInsets.zero,
            child: Row(
              children: [
                Expanded(
                  child: Hero(
                    tag: 'search',
                    child: CupertinoSearchTextField(
                      // onTap: () {
                      //   Navigator.of(context).push(
                      //       PageRouteBuilder(
                      //         pageBuilder: (context, animation, secondaryAnimation) => _searchView(cb),
                      //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      //           const begin = Offset(0.0, 0.175);
                      //           const end = Offset.zero;
                      //           const curve = Curves.ease;
                      //
                      //           var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      //
                      //           return SlideTransition(
                      //             position: animation.drive(tween),
                      //             // sizeFactor: null,
                      //             child: child,
                      //           );
                      //         },
                      //       )
                      //   );
                      // },
                      controller: _searchTextController,
                      onChanged: (value) {
                        if(!cb.isLoading) {
                          ref.read(SEAUserProvider).onRefresh(mounted, _searchTextController.text, widget.filter);
                        }
                      },
                    ),
                  ),
                ),
                const Hero(tag: 'cancel', child: SizedBox(width: 1)),
              ],
            ),
          ),
          if(cb.isLoading)
            const Center(child: CupertinoActivityIndicator()),
          if(!cb.isLoading)
            cb.hasData == false
                ? Center(
                child: Text(
                  'There are no users.',
                  style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey
                  ),
                )
            )
                : Hero(
              tag: 'list',
                  child: ListView.separated(
              padding: widget.listPadding,
              key: PageStorageKey(_searchTextController.text),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 1,
              shrinkWrap: true,
              separatorBuilder: (context, index) => widget.separator ?? const SizedBox(height: 10),
              itemBuilder: (_, int index) {
                  if(cb.data.isEmpty && widget.emptyState != null) {
                    return widget.emptyState!;
                  }
                  if (index < cb.data.length) {
                    return widget.listTile(cb.data[index], cb);
                  }
                  return Opacity(
                    opacity: cb.isLoading ? 1.0 : 0.0,
                    child: cb.lastVisible == null
                        ? const SizedBox() //LoadingCard(height: 250)
                        : const Center(
                      child: SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: CupertinoActivityIndicator()),
                    ),
                  );
              },
            ),
                ),
        ],
      ),
    );
  }

  Widget _searchView(SEAUserNotifier cb) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: widget.searchBarPadding ?? EdgeInsets.zero,
                child: SizedBox(
                  width: getViewportWidth(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Hero(
                          tag: 'search',
                          child: CupertinoSearchTextField(
                            autofocus: true,
                            controller: _searchTextController,
                            onChanged: (value) {
                              if(!cb.isLoading) {
                                ref.read(SEAUserProvider).onRefresh(mounted, _searchTextController.text, widget.filter);
                              }
                            },
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'cancel',
                        child: PlatformTextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel'
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              if(cb.isLoading)
                const Center(child: CupertinoActivityIndicator()),
              if(!cb.isLoading)
                cb.hasData == false
                    ? Center(
                    child: Text(
                      'There are no users.',
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey
                      ),
                    )
                )
                    : ListView.separated(
                  padding: widget.listPadding,
                  key: PageStorageKey(_searchTextController.text),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 1,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => widget.separator ?? const SizedBox(height: 10),
                  itemBuilder: (_, int index) {
                    if(cb.data.isEmpty && widget.emptyState != null) {
                      return widget.emptyState!;
                    }
                    if (index < cb.data.length) {
                      return widget.listTile(cb.data[index], cb);
                    }
                    return Opacity(
                      opacity: cb.isLoading ? 1.0 : 0.0,
                      child: cb.lastVisible == null
                          ? const SizedBox() //LoadingCard(height: 250)
                          : const Center(
                        child: SizedBox(
                            width: 32.0,
                            height: 32.0,
                            child: CupertinoActivityIndicator()),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
