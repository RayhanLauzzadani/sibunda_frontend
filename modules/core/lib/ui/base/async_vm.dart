import 'package:async/async.dart';
import 'package:core/domain/model/result.dart';
import 'package:core/ui/base/live_data.dart';
import 'package:core/util/_consoles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

import '../../domain/model/wrapper.dart';
import 'expirable.dart';
import 'view_model.dart';

//TODO 21 Juni 2021: Tambahi method doOnFail().

/// [ViewModel] that is designed to manage various async process.
/// It can [cancelJob] async process before launching the same process based on [String] key.
/// It can can also invoke [_preAsyncTaskMap] before launching the async process.
abstract class AsyncVm extends ViewModel {

  /// Its values, is a [Tuple2] of [CancelableOperation] and [Var]<bool>.
  /// The [Var]<bool> is for indication of parent async process [CancelableOperation]
  /// whether the parent is active or not. The [Var]<bool> is useful since
  /// The [CancelableOperation] can't cancel the nested async process.
  /// The [Var]<bool> is useful in context of [startJob] invocation.
  /// Note that the [Var]<bool> can't guarantee to stop nested async process.
  /// So, the developers must be aware of the value inside [Var]<bool>.
  /// Developers can use the [Var]<bool> like this:
  ///
  /// startJob(`expirable`, (isActive) async {
  ///   ....
  ///   ....Start of nested async process block....
  ///     if(isActive.value) {
  ///       ....Do some nested async operation....
  ///     }
  ///   ....End of nested async process block....
  ///   ....
  /// });
  Map<String, Tuple2<CancelableOperation, Var<bool>>> _jobMap = {};

  /// For its values, the lambda returns [Widget].
  /// If not null, it means the widget will be rebuilt using the returned [Widget].
  /// If null, the old [Widget] will stay.
  Map<Expirable, void Function(String key)> _preAsyncTaskMap = {};

  /// For its values, the lambda returns [Widget].
  /// If not null, it means the widget will be rebuilt using the returned [Widget].
  /// If null, the old [Widget] will stay.
  ///
  /// These callbacks will be called after all [LiveData.value] possible changes in [startJob]'s block.
  /// Note that these will only be called when there's no error or failure during [startJob]'s block.
  Map<Expirable, void Function(String key)> _postAsyncTaskMap = {};

  /// For its values, the lambda returns [Widget].
  /// If not null, it means the widget will be rebuilt using the returned [Widget].
  /// If null, the old [Widget] will stay.
  Map<Expirable, void Function(String key, Fail failure)> _onFailTaskMap = {};


  @nonVirtual
  void addOnPreAsyncTask(Expirable observer, void Function(String key)? block) {
    if(block != null) {
      _preAsyncTaskMap[observer] = block;
    } else {
      _preAsyncTaskMap.remove(observer);
    }
  }
  @nonVirtual
  void doPreAsyncTask(String key) {
    final removedKeys = <Expirable>{};
    for(final observer in _preAsyncTaskMap.keys) {
      if(observer.isActive) {
        _preAsyncTaskMap[observer]!(key);
      } else {
        removedKeys.add(observer);
      }
      //else { _preAsyncTaskMap.remove(observer); }
    }
    for(final key in removedKeys) {
      _preAsyncTaskMap.remove(key);
    }
  }

  @nonVirtual
  void addOnPostAsyncTask(Expirable observer, void Function(String key)? block) {
    if(block != null) {
      _postAsyncTaskMap[observer] = block;
    } else {
      _postAsyncTaskMap.remove(observer);
    }
  }
  @nonVirtual
  void doPostAsyncTask(String key) {
    final removedKeys = <Expirable>{};
    for(final observer in _postAsyncTaskMap.keys) {
      if(observer.isActive) {
        _postAsyncTaskMap[observer]!(key);
      } else {
        removedKeys.add(observer);
      }
      //else { _preAsyncTaskMap.remove(observer); }
    }
    for(final key in removedKeys) {
      _postAsyncTaskMap.remove(key);
    }
  }

  @nonVirtual
  void addOnFailTask(Expirable observer, void Function(String key, Fail failure)? block) {
    if(block != null) {
      _onFailTaskMap[observer] = block;
    } else {
      _onFailTaskMap.remove(observer);
    }
  }

  @nonVirtual
  void doOnFailTask(String key, Fail failure) {
    final removedKeys = <Expirable>{};
    for(final observer in _onFailTaskMap.keys) {
      if(observer.isActive) {
        _onFailTaskMap[observer]!(key, failure);
      } else {
        removedKeys.add(observer);
        //_onFailTaskMap.remove(observer);
      }
    }
    for(final key in removedKeys) {
      _preAsyncTaskMap.remove(key);
    }
  }

  @nonVirtual
  void cancelJob(String key, {
    bool immediatelyRemove = true,
  }) {
    final pair = _jobMap[key];
    if(pair != null) {
      pair.item1.cancel();
      pair.item2.value = false;
      if(immediatelyRemove) {
        _jobMap.remove(key);
      }
    }
  }

  /// Use this method to [cancelJob] the previous async process with the same [key].
  /// then [doPreAsyncTask] before finally do the [block] process async.
  @nonVirtual
  Future<void> startJob(String key, Future<Fail?> Function(Val<bool> isActive) block) {
    //prind("AsyncVm.startJob() key = $key");
    cancelJob(key);
    doPreAsyncTask(key);
    Future<Fail?> future;
    final isActive = Var(true);
    final pair = Tuple2(CancelableOperation.fromFuture(
        (future = block(isActive)).then((fail) {
          //prind("AsyncVm startJob then after type= $runtimeType key= $key fail= $fail");
          if(fail != null) {
            doOnFailTask(key, fail);
          } else {
            doPostAsyncTask(key);
          }
        })
    ), isActive);
    _jobMap[key] = pair;
    return future;
  }

  /// Check if a job with given [key] is currently running.
  bool isJobRunning(String key) {
    final pair = _jobMap[key];
    if(pair == null) return false;
    return pair.item2.value == true; // isActive flag
  }

  @override
  @mustCallSuper
  void dispose() {
    for(final key in _jobMap.keys) {
      cancelJob(key, immediatelyRemove: false);
    }
    _jobMap.clear();
  }
}