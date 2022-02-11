//
//  APIClient.swift
//  ImageDisplayTests
//
//  Created by Agroya on 08/02/22.
//

import Foundation
import XCTest

protocol URLRequestExecutor {
    @discardableResult
    func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask?
}

extension URLSession: URLRequestExecutor {
    func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let task = self.dataTask(with: url, completionHandler: completion)
        task.resume()
        return task
    }
}

class APIClient {
    
    var url: URL!
    
    private let session: URLRequestExecutor
    
    init(_ session: URLRequestExecutor = URLSession.shared) {
        self.session = session
    }
    
    enum Error: Swift.Error {
        case unauthorisedAccess
        case clientError
    }
    enum APIResult {
        case success(Data?, HTTPURLResponse)
        case failure(Error)
    }
    
    func load(url imageURL: URL, completion: @escaping ((APIResult) -> Void)) {
        self.url = imageURL
        self.session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                completion(.failure(.clientError))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.unauthorisedAccess))
                return
            }
            completion(.success(data, response))
        }
    }
}

class APIClientTests: XCTestCase {
    
    func test_load_url() {
        let sut = client()
        let imageURL = URL(string: "https://a-given-url")!
        sut.load(url: imageURL, completion: {_ in})
        XCTAssertEqual(imageURL, sut.url)
    }
    
    
    func test_loadUrlWhenNoConnectionThrowError() {
        let sutError = APIClient.Error.clientError

        let reslutError = expectErrorResult(data: nil, response: nil, error: sutError)
        
        XCTAssertEqual(reslutError as! APIClient.Error, sutError)
    }
    
    func test_loadUrlWhenAPIKeyMissingThenThrowServerError() {
        let sutError = APIClient.Error.unauthorisedAccess

        let response = HTTPURLResponse(url: getImageURL(), statusCode: 401, httpVersion: nil, headerFields: nil)
        let reslutError = expectErrorResult(data: nil, response: response, error: nil)
        
        XCTAssertEqual(reslutError as! APIClient.Error, sutError)

    }
    
    func test_load_urlWhenServerResponsedAndBlankArray() {
        let response = HTTPURLResponse(url: getImageURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = Data()
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

    private func expect(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> APIClient.APIResult? {
        let sut = client(data: data, response: response, error: error)
        let imageURL = getImageURL()
        let exp = expectation(description: "API Calling")
        var result: APIClient.APIResult?
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
