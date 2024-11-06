//
//  RowContent.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import Foundation

struct RowContent: Decodable {
    let id: Int
    let name: String
    let imageURL: URL?
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image"
    }
}
