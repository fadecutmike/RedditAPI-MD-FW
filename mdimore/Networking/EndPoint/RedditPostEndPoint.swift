//
//  RedditPostEndPoint.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

public enum RedditApi {
    case redditTop(page:String, tp: String)
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
            case .redditTop(let page, var tp):
                if tp.count == 0 { tp = "day" }
                return .requestParameters(bodyParameters: nil, bodyEncoding: .urlEncoding, urlParameters: ["after":page, "count":"50", "sr_detail":1, "t":tp])
        }
    }
}
