//
//  ImageRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol MediaFetcheable {
    func fetchMedia(url: URL) -> AnyPublisher<Media, Error>
}

final class MediaRepository: MediaFetcheable {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClientImpl()) {
        self.networkClient = networkClient
    }
    
    func fetchMedia(url: URL) -> AnyPublisher<Media, Error> {
        return networkClient.download(with: url)
            .map(toMedia)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func toMedia(_ response: DownloadTaskResponse) -> Media {
        Media(
            url: response.url.absoluteString,
            type: MediaType(from: response.urlResponse.mimeMainType),
            fileType: FileType(from: response.urlResponse.mimeSubType)
        )
    }
}
