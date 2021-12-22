import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

enum GetUriKeys {
  users,
  products,
  transaction,
  history,
  groupHasGuests,
  groupCurrent,
  groupMember,
  groups,
  userBalanceSum,
  passwordReminder,
  groupBoost,
  groupGuests,
  groupUnapprovedMembers,
  groupExportXls,
  purchasesAll,
  paymentsAll,
  purchasesFirst6,
  paymentsFirst6,
  statisticsPayments,
  statisticsPurchases,
  statisticsAll,
  requestsAll,
  purchasesDate,
  paymentsDate
}
List<String> getUris = [
  '/customers',
  '/products',
  '/customers/transactions',
  '/history',
  '/groups/{}/has_guests',
  '/groups/{}',
  '/groups/{}/member',
  '/groups',
  '/balance',
  '/password_reminder?username={}',
  '/groups/{}/boost',
  '/groups/{}/guests',
  '/groups/{}/members/unapproved',
  '/groups/{}/export/get_link',
  '/purchases?group={}',
  '/payments?group={}',
  '/purchases?group={}&limit=6',
  '/payments?group={}&limit=6',
  '/groups/{}/statistics/payments?from_date={}&until_date={}',
  '/groups/{}/statistics/purchases?from_date={}&until_date={}',
  '/groups/{}/statistics/all?from_date={}&until_date={}',
  '/requests?group={}',
  '/purchases?group={}&from_date={}&until_date={}',
  '/payments?group={}&from_date={}&until_date={}'
];

enum HttpType { get, post, put, delete }

///Generates URI-s from enum values. The default value of [args] is [currentGroupId].
String generateUri(GetUriKeys key,
    {HttpType type = HttpType.get, List<String>? args}) {
  if (type == HttpType.get) {
    String uri = getUris[key.index];
    if (args != null) {
      for (String arg in args) {
        if (uri.contains('{}')) {
          uri = uri.replaceFirst('{}', arg);
        } else {
          break;
        }
      }
    }
    return uri;
  }
  return '';
}

Widget errorToast(String msg, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.red,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.clear,
          color: Colors.white,
        ),
        SizedBox(
          width: 12.0,
        ),
        Flexible(
            child: Text(msg,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: Colors.white))),
      ],
    ),
  );
}

Duration delayTime() {
  return Duration(milliseconds: 300);
}

Future<http.Response> httpGet(
    {required BuildContext context, required String uri}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Api-Key": "estike1895",
    };
    http.Response response =
        await http.get(Uri.parse(APP_URL + uri), headers: header);
    // print(response.body);
    if (response.statusCode < 300 && response.statusCode >= 200) {
      return response;
    } else {
      // Map<String, dynamic> error = jsonDecode(response.body);
      // throw error['errors'];
      throw response.body;
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpPost(
    {required BuildContext context,
    required String uri,
    Map<String, dynamic>? body,
    bool useGuest = false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
    };
    http.Response response;
    print('1');
    if (body != null) {
      print('2');
      String bodyEncoded = json.encode(body);
      // print(bodyEncoded);
      response = await http.post(Uri.parse(APP_URL + uri),
          headers: header, body: bodyEncoded);
    } else {
      print('3');
      response = await http.post(Uri.parse(APP_URL + uri), headers: header);
    }

    if (response.statusCode < 300 && response.statusCode >= 200) {
      print('4');
      return response;
    } else {
      print('5');
      
      print(response.body);
      Map<String, dynamic> error = jsonDecode(response.body);
      throw error['errors'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    print(_);
    throw _;
  }
}

Future<http.Response> httpPut(
    {required BuildContext context,
    required String uri,
    Map<String, dynamic>? body,
    bool useGuest = false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Api-Key": "estike1895",
    };
    http.Response response;
    if (body != null) {
      String bodyEncoded = json.encode(body);
      response = await http.put(Uri.parse(APP_URL + uri),
          headers: header, body: bodyEncoded);
    } else {
      response = await http.put(Uri.parse(APP_URL + uri), headers: header);
    }

    if (response.statusCode < 300 && response.statusCode >= 200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      print(error);
      throw error['errorMessage'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}

Future<http.Response> httpDelete(
    {required BuildContext context,
    required String uri,
    bool useGuest = false}) async {
  try {
    Map<String, String> header = {
      "Content-Type": "application/json",
      "Api-Key": "estike1895",
    };
    http.Response response =
        await http.delete(Uri.parse(APP_URL + uri), headers: header);

    if (response.statusCode < 300 && response.statusCode >= 200) {
      return response;
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      throw error['errorMessage'];
    }
  } on FormatException {
    throw 'format_exception';
  } on SocketException {
    throw 'cannot_connect';
  } catch (_) {
    throw _;
  }
}
