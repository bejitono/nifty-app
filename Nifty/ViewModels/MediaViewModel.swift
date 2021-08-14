//
//  MediaViewModel.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

struct MediaViewModel: Identifiable, Equatable {
    let id = UUID()
    let url: String
    let type: MediaType
    let fileType: FileType
}

extension MediaViewModel {
    
    init(_ model: Media) {
        self.init(
            url: model.url,
            type: model.type,
            fileType: model.fileType
        )
    }
}
