//
//  File.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import Alamofire
import UIKit

final class NetworkService {
    func getPage(
        number: Int,
        completion: @escaping (Result<PageContent, AFError>) -> ()
    ) {
        let parameters = ["page": String(number)]
        
        AF.request(
            "https://junior.balinasoft.com/api/v2/photo/type",
            parameters: parameters
        )
        .responseDecodable(of: PageContent.self) { response in
            completion(response.result)
        }
    }
}
