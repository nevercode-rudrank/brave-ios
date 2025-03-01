// Copyright 2021 The Brave Authors. All rights reserved.
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import BraveCore

#if DEBUG

class MockTxService: BraveWalletTxService {
  private let txs: [BraveWallet.TransactionInfo] = [
    .previewConfirmedERC20Approve,
    .previewConfirmedSend,
    .previewConfirmedSwap
  ]
  
  func transactionInfo(_ coinType: BraveWallet.CoinType, txMetaId: String, completion: @escaping (BraveWallet.TransactionInfo?) -> Void) {
    completion(txs.first(where: { $0.id == txMetaId }))
  }

  func addUnapprovedTransaction(_ txData: BraveWallet.TxDataUnion, from: String, completion: @escaping (Bool, String, String) -> Void) {
    completion(true, "txMetaId", "")
  }

  func rejectTransaction(_ coinType: BraveWallet.CoinType, txMetaId: String, completion: @escaping (Bool) -> Void) {
  }

  func allTransactionInfo(_ coinType: BraveWallet.CoinType, from: String, completion: @escaping ([BraveWallet.TransactionInfo]) -> Void) {
    completion(txs.map { tx in
      tx.txStatus = .unapproved
      return tx
    })
  }

  func add(_ observer: BraveWalletTxServiceObserver) {
  }

  func speedupOrCancelTransaction(_ coinType: BraveWallet.CoinType, txMetaId: String, cancel: Bool, completion: @escaping (Bool, String, String) -> Void) {
    completion(false, "", "Error Message")
  }

  func retryTransaction(_ coinType: BraveWallet.CoinType, txMetaId: String, completion: @escaping (Bool, String, String) -> Void) {
    completion(false, "", "Error Message")
  }

  func reset() {
  }

  func transactionMessage(toSign coinType: BraveWallet.CoinType, txMetaId: String, completion: @escaping (String?) -> Void) {
    completion("Mock transaction message")
  }

  func approveTransaction(_ coinType: BraveWallet.CoinType, txMetaId: String, completion: @escaping (Bool, BraveWallet.ProviderErrorUnion, String) -> Void) {
    completion(false, .init(providerError: .internalError), "Error Message")
  }
}

#endif
