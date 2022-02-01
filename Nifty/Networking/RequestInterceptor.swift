//
//  RequestInterceptor.swift
//  Nifty
//
//  Created by Stefano on 01.02.22.
//

import Foundation

protocol RequestInterceptable {
    
    func intercept(_ request: URLRequest) -> URLRequest
}

final class EmptyRequestInterceptor: RequestInterceptable {
    
    func intercept(_ request: URLRequest) -> URLRequest {
        request
    }
}
