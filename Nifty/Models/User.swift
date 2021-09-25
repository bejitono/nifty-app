//
//  User.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import Foundation

struct User {
    let wallet: Wallet
}

extension User: UserCacheKeyConvertible {
    static var key: String = "niftyapp.user"
}
