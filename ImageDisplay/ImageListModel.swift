//
//  ImageListModel.swift
//  ImageDisplay
//
//  Created by Agroya on 11/02/22.
//

import Foundation

// MARK: - ImageListModel
struct ImageListModel: Codable {
    let total, totalImages: Int
    let images: [ImageModel]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalImages = "totalHits"
        case images = "hits"
    }
}

// MARK: - Hit
struct ImageModel: Codable {
    let id: Int
    let pageURL: String
    let type: TypeEnum
    let tags: String
    let previewURL: String
    let previewWidth, previewHeight: Int
    let webformatURL: String
    let webformatWidth, webformatHeight: Int
    let largeImageURL: String
    let imageWidth, imageHeight, imageSize, views: Int
    let downloads, collections, likes, comments: Int
    let userID: Int
    let user: String
    let userImageURL: String

    enum CodingKeys: String, CodingKey {
        case id, pageURL, type, tags, previewURL, previewWidth, previewHeight, webformatURL, webformatWidth, webformatHeight, largeImageURL, imageWidth, imageHeight, imageSize, views, downloads, collections, likes, comments
        case userID = "user_id"
        case user, userImageURL
    }
}

enum TypeEnum: String, Codable {
    case photo = "photo"
}

