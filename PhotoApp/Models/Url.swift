//
//  Result.swift
//  AlamofireApp
//
//  Created by Vladislav on 23.06.2020.
//  Copyright © 2020 Vladislav Cheremisov. All rights reserved.
//

import Foundation

struct URLS: Decodable {
    let raw: String?
    let full: String?
    let regular: String?
    let small: String?
    let thumb: String?
    
    init(url: [String: Any]) {
        self.raw = url["raw"] as? String
        self.full = url["full"] as? String
        self.regular = url["regular"] as? String
        self.small = url["small"] as? String
        self.thumb = url["thumb"] as? String
    }
}

enum OrderBy: String, CaseIterable {
    case latest = "latest"
    case oldest = "oldest"
    case popular = "popular"
}

