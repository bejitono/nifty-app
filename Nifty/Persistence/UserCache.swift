//
//  UserCache.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

protocol UserCacheable {
    
    func set<Data>(_ data: Data) where Data: UserCacheKeyConvertible
    func get<Data>() -> Data? where Data: UserCacheKeyConvertible
}

protocol UserCacheKeyConvertible: Codable {
    static var key: String { get }
}

final class UserCache: UserCacheable {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func set<Data>(_ data: Data) where Data: UserCacheKeyConvertible {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: Data.key)
        }
    }
    
    func get<Data>() -> Data? where Data: UserCacheKeyConvertible {
        guard let data = userDefaults.object(forKey: Data.key) as? Foundation.Data,
              let decoded = try? JSONDecoder().decode(Data.self, from: data) else {
            return nil
        }
        return decoded
    }
}
