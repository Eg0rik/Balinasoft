//
//  PageContent.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import Foundation

struct PageContent: Decodable {
    let page: Int
    var pageSize: Int
    let totalPages: Int
    let totalElements: Int
    let content: [RowContent]
}
