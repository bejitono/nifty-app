//
//  NewWalletViewModel.swift
//  Nifty
//
//  Created by Stefano on 19.09.21.
//

import Combine
import Foundation

final class NewWalletViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var address = ""
    @Published var buttonState: AddWalletButtonState = .valid
    
    @Published private var isLoading = false
    private let web3Utils: Web3Utils
    private let ensResolver: ENSResolver
    private let userCache: UserCache
    private var cancellables = Set<AnyCancellable>()
    
    init(userCache: UserCache = UserCache(),
         ensResolver: ENSResolver = ENSRepository(),
         web3Utils: Web3Utils = Web3UtilsImpl()) {
        self.userCache = userCache
        self.ensResolver = ensResolver
        self.web3Utils = web3Utils
        $address
            .sink(receiveValue: onNewAddressInput)
            .store(in: &cancellables)
    }
    
    func isValidEthereumAddress(_ hex: String) -> Bool {
        web3Utils.isValidEthereumAddress(hex)
    }
    
    func onNewAddressInput(_ address: String) {
        if buttonState == .invalid {
            buttonState = .valid
        }
    }
    
    func onAddNewWallet() {
        guard buttonState != .invalid else { return }
        buttonState = .loading
        if isValidEthereumAddress(address) {
            buttonState = .valid
            // handle new address
            let user = User(wallet: Wallet(address: address))
            userCache.set(user)
            self.user = user
            return
        }
        ensResolver.resolve(ens: address)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.buttonState = .valid
                case .failure:
                    self.buttonState = .invalid
                }
            } receiveValue: { [weak self] ethAddress in
                guard let self = self else { return }
                // handle new address
                print("from ens: ", ethAddress)
                let user = User(wallet: Wallet(address: ethAddress))
                self.userCache.set(user)
                self.user = user
            }
            .store(in: &cancellables)
    }
}
