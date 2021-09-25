//
//  Web3Utils.swift
//  Nifty
//
//  Created by Stefano on 19.09.21.
//

import Foundation

protocol Web3Utils {
    func isValidEthereumAddress(_ hex: String) -> Bool
}

struct Web3UtilsImpl: Web3Utils {
    
    func isValidEthereumAddress(_ hex: String) -> Bool {
        guard let _ = try? EthAddress(hex: hex, eip55: true) else { return false }
        return true
    }
}
