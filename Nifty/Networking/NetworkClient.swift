//
//  NetworkClient.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Combine
import Foundation

protocol NetworkClient {
    func request<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, NetworkError> where T: Decodable
    
    func request<T>(
        with url: URL
    ) -> AnyPublisher<T, NetworkError> where T: Decodable
    
    func download(
        with url: URL
    ) -> AnyPublisher<(url: URL, response: URLResponse), NetworkError>
}

final class NetworkClientImpl: NetworkClient {
    
    let interceptor: RequestInterceptable
    
    init(interceptor: RequestInterceptable = EmptyRequestInterceptor()) {
        self.interceptor = interceptor
    }
}

extension NetworkClientImpl {
    
    func request<T>(
        with components: URLComponents
    ) -> AnyPublisher<T, NetworkError> where T: Decodable {
        
        guard let url = components.url else {
            let error = NetworkError.unknown(description: "Couldn't create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let request = interceptor.intercept(URLRequest(url: url))

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(handleResponse)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { NetworkError.unknown(description: $0.localizedDescription) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func request<T>(
        with url: URL
    ) -> AnyPublisher<T, NetworkError> where T: Decodable {

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap(handleResponse)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { NetworkError.unknown(description: $0.localizedDescription) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // https://theswiftdev.com/how-to-download-files-with-urlsession-using-combine-publishers-and-subscribers/
    func download(
        with url: URL
    ) -> AnyPublisher<(url: URL, response: URLResponse), NetworkError> {
        
        // could also think about using urlSession(_:dataTask:didReceive:) to receive chunks of data instead of all at once
        return URLSession.shared.downloadTaskPublisher(for: url)
            .mapError { NetworkError.unknown(description: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> Data {
        print("####", String(data: data, encoding: .utf8))
        if let response = response as? HTTPURLResponse,
           !(200...299).contains(response.statusCode) {
            throw NetworkError.httpError(statusCode: response.statusCode)
        }
        return data
    }
}

enum NetworkError: Error, LocalizedError {
    case httpError(statusCode: Int)
    case unknown(description: String)
}
