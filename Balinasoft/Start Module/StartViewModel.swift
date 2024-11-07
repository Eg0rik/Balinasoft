//
//  StartViewModel.swift
//  Balinasoft
//
//  Created by MAC on 11/6/24.
//

import Foundation
import Alamofire

protocol ImageLoader {
    func loadImage(url: URL, completion: @escaping ((UIImage?) -> Void))
}

final class StartViewModel: ImageLoader {
    
    //MARK: - Public properties
    @Published var pages: [PageContent] = []
    @Published var alertMessage = AlertContent(title: "", message: "")
    
    //MARK: - Private properties
    private let networkService = NetworkService()
    private let imageCache = NSCache<AnyObject, UIImage>()
    private let serialQueue = DispatchQueue(label: "serialQueue")
    
    //MARK: - Init
    init() {
        loadPage(number: 0)
    }
    
    //MARK: - Public methods
    func loadNextPage() {
        let pagesLoaded = pages.count
        
        guard let totalPages = pages.first?.totalPages, pagesLoaded < totalPages else {
            return
        }
        
        //pagesLoaded == number of next page
        loadPage(number: pagesLoaded)
    }
    
    func loadImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        
        if let cachedImage = imageCache.object(forKey: url as AnyObject) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        serialQueue.async { [weak self] in
            guard
                let data = try? Data(contentsOf: url),
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    print("Can't load image from \(url)")
                    completion(nil)
                }
                return
            }
            
            self?.imageCache.setObject(image, forKey: url as AnyObject)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    func uploadImage(image: UIImage, id: Int, name: String) {
        serialQueue.async { [weak self] in
            self?.networkService.uploadImage(image: image, id: id, name: name) { message in
                self?.alertMessage = AlertContent(title: "Multipart request", message: message)
            }
        }
    }
}

//MARK: - Private methods
private extension StartViewModel {
    func loadPage(number: Int) {
        serialQueue.async { [weak self] in
            self?.networkService.getPage(number: number) { result in
                guard let self else { return }
                
                switch result {
                    case .success(let page):
                        self.pages.append(page)
                        
                    case .failure(let err):
                        self.alertMessage = AlertContent(title: String(#function), message: "Can't load page \(number), look at the console")
                        
                        print("Can't load page \(number), AFError:\n\(err)")
                }
            }
        }
    }
}
