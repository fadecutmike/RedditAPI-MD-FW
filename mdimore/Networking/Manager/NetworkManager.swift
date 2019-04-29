//
//  NetworkManager.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

enum NetworkResponse:String {
    case success,
    authError = "Authentication is requied.",
    badRequest = "Bad request",
    failed = "Network request failed.",
    noData = "No data returned.",
    decodeFailed = "Unable to decode response."
}

enum Result<String> {
    case success,
    failure(String)
}

struct NetworkManager {
    let router = Router<RedditApi>()
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
