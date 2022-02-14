//
//  ImageListModel.swift
//  ImageDisplay
//
//  Created by Agroya on 11/02/22.
//

import Foundation

// MARK: - ImageListModel
public struct ImageListModel: Codable {
    public let total, totalImages: Int
    public let images: [ImageModel]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalImages = "totalHits"
        case images = "hits"
    }
}

// MARK: - Hit
public struct ImageModel: Codable {
    public let id: Int
    public let pageURL: String
    public let type: TypeEnum
    public let tags: String
    public let previewURL: String
    public let previewWidth, previewHeight: Int
    public let webformatURL: String
    public let webformatWidth, webformatHeight: Int
    public let largeImageURL: String
    public let imageWidth, imageHeight, imageSize, views: Int
    public let downloads, collections, likes, comments: Int
    public let userID: Int
    public let user: String
    public let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, collections, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}

public enum TypeEnum: String, Codable {
    case photo = "photo"
}

