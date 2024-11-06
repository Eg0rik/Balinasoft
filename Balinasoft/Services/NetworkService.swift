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
    
    func uploadImage(image: UIImage, id: Int, name: String, messageCompletion: @escaping (String) -> Void) {
        
        let urlString = "https://junior.balinasoft.com/api/v2/photo"
        
        guard
            let nameData = name.data(using: .utf8),
            let idData = id.description.data(using: .utf8),
            let imageData = image.jpegData(compressionQuality: 0.1)
        else {
            print("\(#function) - can't transform values to data using .utf8")
            return
        }
        
        let fileName = "image_\(UUID()).jpeg"
        
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(nameData, withName: "name")
            multipartFormData.append(idData, withName: "typeId")
            multipartFormData.append(imageData, withName: "photo",fileName: fileName, mimeType: "image/jpeg")
            
        },to: urlString, method: .post).response { aFDataResponse in
            if let statusCode = aFDataResponse.response?.statusCode,
                statusCode == 200 {
                messageCompletion("The \(fileName) was successfully sent with status code \(statusCode)")
            } else {
                messageCompletion("Error when sending multipartFormData to server, look at console")
                debugPrint(aFDataResponse)
            }
        }
    }
}
