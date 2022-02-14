//
//  ImageLoaderImplment.swift
//  ImageDisplay
//
//  Created by Virender Dall on 14/02/22.
//

import Foundation

public class ImageLoaderImplment: ImageLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func getImages(url: URL, completion: @escaping((ImageResult) -> Void)) {
        client.load(url: url) { (result) in
            switch result {
            case .success(let data, _):
                do{
                    let model = try JSONDecoder().decode(ImageListModel.self, from: data!)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
