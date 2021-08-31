//
//  DownloadTask.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Combine
import Foundation

typealias DownloadTaskResponse = (url: URL, urlResponse: URLResponse)

extension URLSession {

    public func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
        self.downloadTaskPublisher(for: .init(url: url))
    }

    public func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
        .init(request: request, session: self)
    }

    public struct DownloadTaskPublisher: Publisher {

        public typealias Output = (url: URL, response: URLResponse)
        public typealias Failure = URLError

        public let request: URLRequest
        public let session: URLSession

        public init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }

        public func receive<S>(subscriber: S) where S: Subscriber,
            DownloadTaskPublisher.Failure == S.Failure,
            DownloadTaskPublisher.Output == S.Input
        {
            let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
            subscriber.receive(subscription: subscription)
        }
    }
}

extension URLSession {

    final class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
        SubscriberType.Input == (url: URL, response: URLResponse),
        SubscriberType.Failure == URLError
    {
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionDownloadTask!

        init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else {
                return
            }
            self.task = self.session.downloadTask(with: request) { [weak self] url, response, error in
                if let error = error as? URLError {
                    self?.subscriber?.receive(completion: .failure(error))
                    return
                }
                guard let response = response else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
                    return
                }
                if let response = response as? HTTPURLResponse,
                   !(200...299).contains(response.statusCode) {
                    self?.subscriber?.receive(completion: .failure(URLError(.noPermissionsToReadFile)))
                    return
                }
                guard let url = url else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
                    return
                }
                do {
                    let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let mimeSubtype = response.mimeSubType
                    let fileExtension: String = mimeSubtype.contains("svg") ? "svg" : mimeSubtype
                    let fileURL: URL = directoryURL
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(fileExtension)
                    try FileManager.default.moveItem(atPath: url.path, toPath: fileURL.path)
                    _ = self?.subscriber?.receive((url: fileURL, response: response))
                    self?.subscriber?.receive(completion: .finished)
                }
                catch {
                    self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                }
            }
            self.task.resume()
        }

        func cancel() {
            self.task.cancel()
        }
    }
}

extension URLResponse {
    
    var mimeSubType: String {
        String(self.mimeType?.split(separator: "/").last ?? "")
    }
    
    var mimeMainType: String {
        String(self.mimeType?.split(separator: "/").first ?? "")
    }
}
