import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sea/models/TenantModel.dart';
import 'package:sea/services/configuration.dart';
import 'package:sea/services/providers.dart';
import 'package:sea/services/routing_helper.dart';
import '../login/login.dart';

class SchoolSelection extends ConsumerStatefulWidget {
  const SchoolSelection({Key? key}) : super(key: key);

  @override
  ConsumerState<SchoolSelection> createState() => _SchoolSelectionState();
}

class _SchoolSelectionState extends ConsumerState<SchoolSelection> {


  @override
  Widget build(BuildContext context) {
    final tenantsAsyncValue = ref.watch(allTenantsStreamProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          '*Placeholder for Logo*',
          style: AppConfiguration.appBarTitleStyle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "What's your school's name?",
              style: AppConfiguration.header1,
            ),
            const SizedBox(height: 8),
            tenantsAsyncValue.when(
                data: (tenants) {
                  return TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: AppConfiguration.inputDecoration1.copyWith(
                        hintText: 'Enter school name or district...',
                        isDense: true
                      ),
                      autofocus: true,
                    ),
                    noItemsFoundBuilder: (context) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        child: Text(
                          'School or district not found.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context) => PlatformCircularProgressIndicator(),
                    suggestionsCallback: (pattern) {
                      if(pattern.isEmpty) {
                        return <TenantModel>[];
                      }
                      return tenants.where((t) => t.name.toLowerCase().contains(pattern.toLowerCase())).toList();
                    },
                    suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      shadowColor: Colors.black.withOpacity(0.25)
                    ),
                    itemBuilder: (BuildContext context, TenantModel suggestion) {
                      return ListTile(
                        horizontalTitleGap: 2,
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          backgroundImage: NetworkImage(
                            suggestion.logoURL,
                          )
                        ),
                        title: Text(
                          suggestion.name,
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      );
                    },
                    onSuggestionSelected: (TenantModel suggestion) {
                      RoutingUtil.push(context, Login(tenant: suggestion));
                    },
                  );
                },
                loading: () => TextFormField(decoration: AppConfiguration.inputDecoration1.copyWith(hintText: 'Loading...')),
                error: (e,__) => Text(e.toString())
            )

          ],
        ),
      ),
    );
  }
}