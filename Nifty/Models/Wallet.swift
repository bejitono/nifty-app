//
//  Wallet.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import Foundation

struct Wallet: Equatable {
    let address: String
}

extension Wallet: UserCacheKeyConvertible {
    static var key: String = "niftyapp.wallet"
}
