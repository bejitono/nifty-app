//
//  Collection+SafeUnwrap.swift
//  Nifty
//
//  Created by Stefano on 03.09.21.
//

extension Collection {

    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
