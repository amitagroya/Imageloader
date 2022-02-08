//
//  APIClient.swift
//  ImageDisplayTests
//
//  Created by Agroya on 08/02/22.
//

import XCTest

protocol ImageLoader {
    func getImages(url: URL)
}


class APIClientTest: XCTestCase {

    func load_url() {
        
        let sut = APIClient()
        let imageURL = URL(string: "https://a-given-url")
        sut.load(url: imageURL)
        
        XCTAssertEqual(imageURL, client.url)
    }
   
}
