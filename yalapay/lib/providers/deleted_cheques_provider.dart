// This notifier is used to remove cheque deposits that are empty to prevent bad state element error
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeletedChequesNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    return [];
  }

  addRecentlyDeletedCheques(List<int> deletedCheques) {
    for (var chequeNo in deletedCheques) {
      state = [...state, chequeNo];
    }
  }

  removeRecentlyDeletedCheques() => state = [];
}

final deletedChequesNotfierProvider =
    NotifierProvider<DeletedChequesNotifier, List<int>>(
        () => DeletedChequesNotifier());
