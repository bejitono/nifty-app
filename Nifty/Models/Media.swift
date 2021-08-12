//
//  Media.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

struct Media: Equatable {
    let url: URL
    let type: MediaType
    let fileType: FileType
}

enum MediaType: String {
    case image
    case video
    case unknown
    
    init(from rawValue: String) {
        self = .init(rawValue: rawValue) ?? .unknown
    }
}

enum FileType: String {
    case jpg
    case png
    case mp4
    case gif
    case svg = "svg+xml"
    case unknown
    
    init(from rawValue: String) {
        self = .init(rawValue: rawValue) ?? .unknown
    }
}
