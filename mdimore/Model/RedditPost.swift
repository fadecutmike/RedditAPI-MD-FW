//
//  RedditPost.swift
//  rtest
//
//  Created by Michael Dimore on 4/25/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

struct RootRedditPostJSONData: Decodable {
    let data: Listing?
}

struct Listing: Decodable {
    let children: [Child]?
    
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    init(from decoder: Decoder) throws {
        let redditPostContainer = try decoder.container(keyedBy: CodingKeys.self)
        children = try redditPostContainer.decode([Child].self, forKey: .children)
    }
}

struct Child: Decodable {
    let data: RedditPost
}

struct RedditPost {
    let title: String
    let author: String
    let dateCreated: Date
    let commentCount: Int
    let thumbnail: String?
    let url: String?
    let subreddit: String?
}

extension RedditPost: Decodable {
    
    enum RedditPostCodingKeys: String, CodingKey {
        case title, author, dateCreated = "created", commentCount = "num_comments", thumbnail, url, subreddit
    }
    
    init(from decoder: Decoder) throws {
        let redditPostContainer = try decoder.container(keyedBy: RedditPostCodingKeys.self)
        title = try redditPostContainer.decode(String.self, forKey: .title)
        author = try redditPostContainer.decode(String.self, forKey: .author)
        let created = try redditPostContainer.decode(TimeInterval.self, forKey: .dateCreated)
        dateCreated = Date(timeIntervalSince1970: created)
        commentCount = try redditPostContainer.decode(Int.self, forKey: .commentCount)
        thumbnail = try redditPostContainer.decode(String.self, forKey: .thumbnail)
        url = try redditPostContainer.decode(String.self, forKey: .url)
        subreddit = try redditPostContainer.decode(String.self, forKey: .subreddit)
    }
}

