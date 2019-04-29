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
    func getRedditPosts(page: String, timeperiod: String, completion: @escaping (_ listingIndex: ListingIndex?, _ posts: [RedditPost]?,_ error: String?)->()) {
        
        router.request(.redditTop(page: page, tp: timeperiod)) { data, response, error in
            guard error == nil else {
                completion(nil, nil, error.debugDescription)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(RootRedditPostJSONData.self, from: responseData)
                        if let topData = apiResponse.data {
                            let posts = topData.children?.map({$0.data})
                            completion(topData.index, posts, nil)
                        }
                    } catch {
                        print("NetworkManager, error: \(error)")
                        completion(nil, nil, NetworkResponse.decodeFailed.rawValue)
                    }
                case .failure(let networkFailureError):
                    completion(nil, nil, networkFailureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
