//
//  APIClient.swift
//  ImageDisplayTests
//
//  Created by Agroya on 08/02/22.
//

import Foundation
import XCTest
import ImageDisplay

class APIClientTests: XCTestCase {
    func test_loadUrlWhenNoConnectionThrowError() {
        let sutError = APIError.clientError

        let reslutError = expectErrorResult(data: nil, response: nil, error: sutError)
        
        XCTAssertEqual(reslutError as! APIError, sutError)
    }
    
    func test_loadUrlWhenAPIKeyMissingThenThrowServerError() {
        let sutError = APIError.unauthorisedAccess

        let response = HTTPURLResponse(url: getImageURL(), statusCode: 401, httpVersion: nil, headerFields: nil)
        let reslutError = expectErrorResult(data: nil, response: response, error: nil)
        
        XCTAssertEqual(reslutError as! APIError, sutError)

    }
    
    func test_load_urlWhenServerResponsedAndBlankArray() {
        let response = HTTPURLResponse(url: getImageURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
        let result = expectResult(data: data, response: response, error: nil)
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response?.url)
        XCTAssertEqual(result?.response.statusCode, response?.statusCode)
    }
    
    func test_load_urlWhenServerResponsedWithImageArray() {
        let response = HTTPURLResponse(url: getImageURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = readJsonFile(name: "CapturedImages")
        let result = expectResult(data: data, response: response, error: nil)
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response?.url)
        XCTAssertEqual(result?.response.statusCode, response?.statusCode)
    }
    
    
    
    private func client(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) ->  APIClient {
        let sesion = MockRequestExcecutor(data:data, response:response, error:error)
        let sut = APIClient(sesion)
        return sut;
    }
    
    private func expectErrorResult(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> Error? {
        let result = expect(data: data, response: response, error: error)
            switch result {
            case .failure(let expectedError):
               return expectedError
            default:
                XCTFail("Expecting error response instead")
            }

        return nil
    }
    
    private func expectResult(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> (data: Data?, response: HTTPURLResponse)? {
        let result = expect(data: data, response: response, error: error)
            switch result {
            case let .success(data, response):
               return (data, response)
            default:
                XCTFail("Expecting error response instead")
            }
        return nil
    }

    private func expect(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> APIResult? {
        let sut = client(data: data, response: response, error: error)
        let imageURL = getImageURL()
        let exp = expectation(description: "API Calling")
        var result: APIResult?
        sut.load(url: imageURL) { (expectedResult) in
            result = expectedResult
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return result
    }
    
    private func getImageURL() -> URL {
        return URL(string: "https://a-given-url")!
    }
    
    private class MockRequestExcecutor: URLRequestExecutor {
        private var data: Data?
        private var response: URLResponse?
        private var error: Error?
        
        fileprivate init(data: Data?, response: URLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
            completion(data,response,error)
            return nil
        }
    }
}

extension XCTestCase {
    public func readJsonFile(name: String) -> Data {
        let bundle = Bundle(for: APIClientTests.self)
        guard let path = bundle.path(forResource: name, ofType: ".json") else {
            fatalError("File path not found")
        }
        return try! Data(contentsOf: URL(fileURLWithPath: path))
    }
}
