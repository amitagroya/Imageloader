//
//  ImageLoaderTests.swift
//  ImageDisplayTests
//
//  Created by Agroya on 11/02/22.
//

import XCTest
import ImageDisplay

class ImageLoaderImplment: ImageLoader {
    let client: HTTPClient
//    private var messages: [URL: ((ImageResult) -> Void)] = [:]
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    enum ImageResult {
        case success(ImageListModel)
        case failure(Error)
    }
    
    func getImages(url: URL, completion: @escaping((ImageResult) -> Void)) {
        
        client.load(url: url) { (result) in
            
        }
    }
    
    
//    private func compeltion(with error: Error) {
//
//    }
}



class ImageLoaderTests: XCTestCase {

    func test_load_apiClientReturnError() {
        let client = HTTPClientSpy()
        let sut = ImageLoaderImplment(client: client)
        let imageURL = URL(string: "http//a-url")!
        sut.getImages(url: imageURL) { images in
            XCTAssertNotNil(images)
        }
    }
    
    class HTTPClientSpy: HTTPClient {
        func load(url imageURL: URL, completion: @escaping ((APIResult) -> Void)) {
            
        }
        
        
        
    }
    
}
