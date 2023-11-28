part of '../repository_interface.dart';

abstract class IGetOptions {
  final bool useCache;
  IGetOptions({
    this.useCache = false,
  });
}

abstract class ISaveOptions {}

abstract class IDeleteOptions {}

abstract class ICreateOrUpdateOptions {
  final bool useTransaction;
  final bool useCache;
  ICreateOrUpdateOptions({
    this.useTransaction = true,
    this.useCache = false,
  }) {
    assert(!(useTransaction && useCache));
  }
}
