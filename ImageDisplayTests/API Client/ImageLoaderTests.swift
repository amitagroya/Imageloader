//
//  ImageLoaderTests.swift
//  ImageDisplayTests
//
//  Created by Agroya on 11/02/22.
//

import XCTest
import ImageDisplay

class ImageLoaderTests: XCTestCase {
    
    func test_load_apiClientReturnError() {
        let client = HTTPClientSpy()
        let expectedResult = APIResult.failure(APIError.clientError)
        client.completeWith(result: expectedResult)
        let sut = ImageLoaderImplment(client: client)
        let imageURL = URL(string: "http//a-url")!
        let exp = expectation(description: "waiting for API result response")
        sut.getImages(url: imageURL) { images in
            switch (images, expectedResult) {
            case let (.failure(error as APIError), .failure(expectedError)):
                XCTAssertEqual(error, expectedError)
            default:
                XCTFail("Expected result was failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_apiClientWhenHaveDataReturnImageListModel(){
        let data = readJsonFile(name: "CapturedImages")
        let imageURL = URL(string: "http//a-url")!
        let httpResponse = HTTPURLResponse(url: imageURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let client = HTTPClientSpy()
        let expectedResult = APIResult.success(data, httpResponse)
        client.completeWith(result: expectedResult)
        let sut = ImageLoaderImplment(client: client)
        let exp = expectation(description: "waiting for API result response")
        sut.getImages(url: imageURL) { images in
            switch images {
            case .success(let imageModel):
                XCTAssertEqual(9, imageModel.images.count)
            default:
                XCTFail("Expected result was failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_load_apiClientReturnRandomDataReturnError(){
        let data = "random data".data(using: .utf8)
        let imageURL = URL(string: "http//a-url")!
        let httpResponse = HTTPURLResponse(url: imageURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let client = HTTPClientSpy()
        let expectedResult = APIResult.success(data, httpResponse)
        client.completeWith(result: expectedResult)
        let sut = ImageLoaderImplment(client: client)
        let exp = expectation(description: "waiting for API result response")
        sut.getImages(url: imageURL) { images in
            switch images {
            case .failure(let error):
                XCTAssertTrue(error is DecodingError)
            default:
                XCTFail("Expected result was failure")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var result: APIResult!
        
        func completeWith(result: APIResult) {
            self.result = result
        }
        
        func load(url imageURL: URL, completion: @escaping ((APIResult) -> Void)) {
            completion(result)
        }
    }
    
}
