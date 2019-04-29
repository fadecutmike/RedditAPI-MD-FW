//
//  RedditPost.swift
//  mdimore
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
    let index: ListingIndex?
    
    enum CodingKeys: String, CodingKey {
        case children, before, after
    }
    
    init(from decoder: Decoder) throws {
        let redditPostContainer = try decoder.container(keyedBy: CodingKeys.self)
        children = try redditPostContainer.decode([Child].self, forKey: .children)
        let before = try redditPostContainer.decode(String.self, forKey: .before)
        let after = try redditPostContainer.decode(String.self, forKey: .after)
        index = ListingIndex(before: before, after: after)
    }
}

struct ListingIndex: Decodable {
    let before: String?
    let after: String
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
    let permalink: String?
    let srDetail: SubRedditInfo?
}

extension RedditPost: Decodable {
    
    enum RedditPostCodingKeys: String, CodingKey {
        case title, author, dateCreated = "created", commentCount = "num_comments", thumbnail, url, subreddit, permalink, srDetail = "sr_detail"
    }
    
    func isImageURL() -> Bool {
        if let str = url, str.count > 2 {
            return ["png", "jpg", "gif"].contains(str.suffix(3))
        }
        return false
    }
    
    var imageURL: URL? {
        if let str = url, isImageURL() { return URL(string: str) }
        return nil
    }
    
    var pageURL: URL? {
        if let str = permalink { return URL(string: "https://reddit.com\(str)") }
        return nil
    }
    
    var thumbnailURL: URL? {
        if let str = thumbnail { return URL(string: str) }
        return nil
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
        permalink = try redditPostContainer.decode(String.self, forKey: .permalink)
        srDetail = try redditPostContainer.decode(SubRedditInfo.self, forKey: .srDetail)
    }
}
