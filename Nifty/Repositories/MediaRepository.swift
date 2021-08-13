//
//  ImageRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol MediaFetcheable {
    func fetchMediaFromPersistenceStore(from hash: NFTHash) -> Media?
    func fetchMedia(url: URL, hash: NFTHash) -> AnyPublisher<Media, Error>
}

final class MediaRepository: MediaFetcheable {
    
    private let cache: UserCache
    private let networkClient: NetworkClient
    
    init(cache: UserCache = UserCache(),
         networkClient: NetworkClient = NetworkClientImpl()) {
        self.cache = cache
        self.networkClient = networkClient
    }
    
    func fetchMediaFromPersistenceStore(from hash: NFTHash) -> Media? {
        guard let mediaDictionary: [NFTHash: NFTCacheDto] = cache.get(),
              let mediaDto = mediaDictionary[hash],
              let fileName = mediaDictionary[hash]?.mediaURL,
              let url = getSavedMediaURL(named: fileName) else {
            return nil
        }
        return Media(mediaDto, url)
    }
    
    func fetchMedia(url: URL, hash: NFTHash) -> AnyPublisher<Media, Error> {
        return networkClient.download(with: url)
            .map(toMedia)
            .map { [cache] media in
                var mediaDictionary: [NFTHash: NFTCacheDto] = cache.get() ?? [hash: NFTCacheDto(media)]
                mediaDictionary[hash] = NFTCacheDto(media)
                cache.set(mediaDictionary)
                return media
            }
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func toMedia(_ response: DownloadTaskResponse) -> Media {
        Media(
            url: response.url,
            type: MediaType(from: response.urlResponse.mimeMainType),
            fileType: FileType(from: response.urlResponse.mimeSubType)
        )
    }
    
    private func getSavedMediaURL(named name: String) -> URL? {
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name)
    }
}
