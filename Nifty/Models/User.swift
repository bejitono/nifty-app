//
//  User.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import Foundation
import SwiftUI

struct User {
    let wallet: Wallet
    let settings: Settings
}

struct Settings {
    let sort: SortItem.SortType
}

extension User: UserCacheKeyConvertible {
    static var key: String = "niftyapp.user"
}

extension Settings: UserCacheKeyConvertible {
    static var key: String = "niftyapp.settings"
}

extension SortItem.SortType: UserCacheKeyConvertible {
    static var key: String = "niftyapp.SortType"
}

