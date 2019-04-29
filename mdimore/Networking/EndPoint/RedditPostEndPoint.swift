//
//  RedditPostEndPoint.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

public enum RedditApi {
    case redditTop
}

extension RedditApi: EndPointType {
    
    var baseURL: URL {
        guard let url = URL(string: "https://reddit.com/") else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self { case .redditTop: return "top/.json" }
    }
    
    var httpMethod: HTTPMethod { return .get }
    var headers: HTTPHeaders? { return nil }
    
    var task: HTTPTask {
        switch self {
            case .redditTop:
                return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: [ "count":"50"])
        }
    }
}
