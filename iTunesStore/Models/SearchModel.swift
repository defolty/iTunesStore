//
//  SearchModel.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 02.09.2022.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    
    var artistName: String? = ""
    var trackName: String? = ""
    var kind: String? = ""
    var imageSmall = ""
    var imageLarge = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    var description: String {
        return "\nKind: \(kind ?? "Nope kind"), Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case kind, artistName, trackName
        case trackPrice, currency
    }
}
