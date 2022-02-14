//
//  ImageLoader.swift
//  ImageDisplay
//
//  Created by Agroya on 11/02/22.
//

import Foundation

public protocol ImageLoader {
    func getImages(url: URL, completion: @escaping((ImageResult) -> Void))
}

public enum ImageResult {
    case success(ImageListModel)
    case failure(Error)
}
