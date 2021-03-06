//
//  APIClient.swift
//  ImageDisplay
//
//  Created by Agroya on 11/02/22.
//

import Foundation

public protocol URLRequestExecutor {
    @discardableResult
    func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask?
}

extension URLSession: URLRequestExecutor {
    public func dataTask(with url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask? {
        let task = self.dataTask(with: url, completionHandler: completion)
        task.resume()
        return task
    }
}

public enum APIResult {
    case success(Data?, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func load(url imageURL: URL, completion: @escaping ((APIResult) -> Void))
}

public class APIClient: HTTPClient {
    private let session: URLRequestExecutor
    
    public init(_ session: URLRequestExecutor = URLSession.shared) {
        self.session = session
    }
    
    public enum Error: Swift.Error {
        case unauthorisedAccess
        case clientError
    }
    
    public func load(url imageURL: URL, completion: @escaping ((APIResult) -> Void)) {
        self.session.dataTask(with: imageURL) { (data, response, error) in
            if error != nil {
                completion(.failure(Error.clientError))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(Error.unauthorisedAccess))
                return
            }
            completion(.success(data, response))
        }
    }
}
