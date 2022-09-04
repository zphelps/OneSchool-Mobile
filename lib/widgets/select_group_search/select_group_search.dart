import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sea/models/GroupModel.dart';
import 'package:sea/widgets/select_group_search/group_search_bloc.dart';

class SelectGroupSearch extends ConsumerStatefulWidget {
  final EdgeInsets? listPadding;
  final EdgeInsets? searchBarPadding;
  final Widget Function(GroupModel, GroupSearchNotifier) listTile;
  final Widget? separator;
  final Future<bool> Function(GroupModel)? filter;
  const SelectGroupSearch({Key? key,
    required this.listTile,
    this.listPadding,
    this.searchBarPadding,
    this.separator,
    this.filter,
  }) : super(key: key);

  @override
  ConsumerState<SelectGroupSearch> createState() => _SelectGroupSearchState();
}

class _SelectGroupSearchState extends ConsumerState<SelectGroupSearch> {

  final _searchTextController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  final groupProvider = ChangeNotifierProvider.autoDispose<GroupSearchNotifier>((ref) {
    return GroupSearchNotifier();
  });

  void _feedScrollListener() {
    final ap = ref.read(groupProvider);
    if (!ap.isLoading) {
      if (scrollController.offset >= scrollController.position.maxScrollExtent && !scrollController.position.outOfRange) {
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

    final fp = ref.read(groupProvider);

    if(mounted){
      fp.data.isNotEmpty ? print('data already loaded') :
      fp.getData(mounted, null, widget.filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cb = ref.watch(groupProvider);
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Padding(
            padding: widget.searchBarPadding ?? EdgeInsets.zero,
            child: CupertinoSearchTextField(
              controller: _searchTextController,
              onChanged: (value) {
                if(!cb.isLoading) {
                  ref.read(groupProvider).onRefresh(mounted, _searchTextController.text, widget.filter);
                }
              },
            ),
          ),
          if(cb.isLoading)
            const Center(child: CupertinoActivityIndicator()),
          if(!cb.isLoading)
            cb.hasData == false
                ? Center(
                child: Text(
                  'There are no groups.',
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
              itemCount: cb.data.isNotEmpty ? cb.data.length + 1 : 5,
              shrinkWrap: true,
              separatorBuilder: (context, index) => widget.separator ?? const SizedBox(height: 10),
              itemBuilder: (_, int index) {
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
    );
  }
}
