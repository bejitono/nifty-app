//
//  ENSRepository.swift
//  Nifty
//
//  Created by Stefano on 19.09.21.
//

import Combine
import Foundation
import web3

typealias ENSName = String

protocol ENSResolver {
    func resolve(address: String) -> AnyPublisher<ENSName, Error>
    func resolve(ens: ENSName) -> AnyPublisher<String, Error>
}

final class ENSRepository: ENSResolver {
    
    private lazy var ensService: EthereumNameService = {
        let infuraURL = URL(string: AppConstants.infuraRpcURL)!
        let client = EthereumClient(url: infuraURL)
        return EthereumNameService(client: client)
    }()
    
    func resolve(address: String) -> AnyPublisher<ENSName, Error> {
        Deferred {
            Future<ENSName, Error> { promise in
                self.ensService.resolve(address: EthereumAddress(address)) { error, ensName in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let ensName = ensName else {
                        promise(.failure(ENSError.noENSNameReceived))
                        return
                    }
                    promise(.success(ensName))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func resolve(ens: ENSName) -> AnyPublisher<String, Error> {
        Deferred {
            Future<String, Error> { promise in
                self.ensService.resolve(ens: ens) { error, address in
                    if let error = error {
                        return promise(.failure(error))
                    }
                    
                    guard let address = address else {
                        return promise(.failure(ENSError.noAddressReceived))
                    }
                    
                    if address == .zero {
                        return promise(.failure(ENSError.nameNotRegistered))
                    }
                    promise(.success(address.value))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

enum ENSError: Error {
    case noENSNameReceived
    case noAddressReceived
    case nameNotRegistered
}
