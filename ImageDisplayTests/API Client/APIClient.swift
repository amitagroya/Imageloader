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
    
    func load(url imageURL: URL, completion: @escaping ((Error?) -> Void)) {
        self.url = imageURL
        self.session.dataTask(with: url) { (data, response, error) in
            if let error =  error {
                completion(Error.clientError)
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(Error.unauthorisedAccess)
                return
            }
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
        let sut = client(error: sutError)
        let imageURL = URL(string: "https://a-given-url")!
        let exp = expectation(description: "API Calling")
        sut.load(url: imageURL) { (error) in
            XCTAssertEqual(error, sutError)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadUrlWhenAPIKeyMissingThenThrowServerError() {
        let sutError = APIClient.Error.unauthorisedAccess
        let imageURL = URL(string: "https://a-given-url")!
        let response = HTTPURLResponse(url: imageURL, statusCode: 401, httpVersion: nil, headerFields: nil)
        let sut = client(response: response)
        let exp = expectation(description: "API Calling")
        sut.load(url: imageURL) { (error) in
            XCTAssertEqual(error, sutError)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private func client(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) ->  APIClient {
        let sesion = MockRequestExcecutor(data:data, response:response, error:error)
        let sut = APIClient(sesion)
        return sut;
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
