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
    case staticImage
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

extension Media {
    init?(_ cacheDto: MediaCacheDto?, _ url: URL) {
        guard let cacheDto = cacheDto else {
            assertionFailure("Expected dto")
            return nil
        }
        self.url = url
        self.type = cacheDto.type
        self.fileType = cacheDto.fileType
    }
}

struct MediaCacheDto: Codable {
    let mediaURL: String
    let type: MediaType
    let fileType: FileType
}

extension MediaCacheDto {
    
    init?(_ model: Media?) {
        guard let model = model else {
            assertionFailure("Expected dto")
            return nil
        }
        self.mediaURL = model.url.lastPathComponent
        self.type = model.type
        self.fileType = model.fileType
    }
}
