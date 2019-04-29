//
//  SubRedditInfo.swift
//  mdimore
//
//  Created by Michael Dimore on 4/28/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import Foundation

struct SubRedditInfo {
    let name: String?
    let icon: String?
}

extension SubRedditInfo: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case name = "display_name", icon = "icon_img"
    }
    
    var iconImageURL: URL? {
        if let str = icon, str.count > 4 { return URL(string: str) }
        return nil
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        icon = try values.decodeIfPresent(String.self, forKey: .icon)
    }
}
