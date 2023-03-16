 
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
 

typedef PrintNative = Void Function(Pointer<Utf8> data);
typedef PrintDart = void Function(Pointer<Utf8> data);

typedef CalculationNative = Int Function(Int num1, Int num2);
typedef CalculationDart = int Function(int num1, int num2);

typedef RequestNative = Pointer<Utf8> Function(Pointer<Utf8> data);
typedef RequestDart = Pointer<Utf8> Function(Pointer<Utf8> data);

class LLaMa {
  String path_lib = "llama.so";
  LLaMa({String? pathLib}) {
    if (pathLib != null) {
      path_lib = pathLib;
    }
  }

  DynamicLibrary library({
    String? pathLib,
  }) {
    pathLib ??= path_lib;
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.process();
    } else {
      return DynamicLibrary.open(pathLib);
    }
  }

  void print({
    required String data,
    String? pathLib,
  }) {
    Pointer<Utf8> data_native = data.toNativeUtf8();
    library(pathLib: pathLib).lookupFunction<PrintNative, PrintDart>("print").call(data_native);
    malloc.free(data_native);
    return;
  }

  int calculate({
    required int num1,
    required int num2,
    String? pathLib,
  }) {
    int calculation_result = library(pathLib: pathLib).lookupFunction<CalculationNative, CalculationDart>("calculate").call(num1, num2);
    return calculation_result;
  }

  Map request({
    required Map data,
    String? pathLib,
  }) {
    Pointer<Utf8> data_native = json.encode(data).toNativeUtf8();
    Pointer<Utf8> request_result = library(pathLib: pathLib).lookupFunction<RequestNative, RequestDart>("request").call(data_native);
    malloc.free(data_native);
    Map result = json.decode(request_result.toDartString());
    malloc.free(request_result);
    return result;
  }
}
