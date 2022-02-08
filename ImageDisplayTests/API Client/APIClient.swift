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
    
    func load(url imageURL: URL, completion: @escaping ((Error?) -> Void)) {
        self.url = imageURL
        self.session.dataTask(with: url) { (data, response, error) in
            completion(error)
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
        let sutError = NSError(domain: "Internet not available", code: 1)
        let sut = client(error: sutError)
        let imageURL = URL(string: "https://a-given-url")!
        let exp = expectation(description: "API Calling")
        sut.load(url: imageURL) { (error) in
            XCTAssertEqual(error! as NSError, sutError)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func client(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) ->  APIClient {
        let sesion = MockRequestExcecutor(data:data, response:response, error:error)
        let sut = APIClient(sesion)
        return sut;
    }
   
    
    class MockRequestExcecutor: URLRequestExecutor {
        private var data: Data?
        private var response: URLResponse?
        private var error: Error?
        
        init(data: Data?, response: URLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
            if let data = data {
                completion(data, response, nil)
            } else {
                completion(nil,nil,error)
            }
            return nil
        }
    }
}
