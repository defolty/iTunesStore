//
//  SearchModel.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 02.09.2022.
//

import Foundation

/**
 Принимает два объекта `SearchResult` и возвращает `true`,
 если первый объект должен быть раньше второго, и `false` в противном случае.
 Например, так:
    `searchResultA.name` = "Waltz for Debby"
    `searchResultB.name` = "Autumn Leaves"

    `searchResultA < searchResultB`  // false
    `searchResultB < searchResultA`  // true
 */
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) ==
        .orderedAscending
}

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
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: break
        }
        return "Unknown"
    }
    
    var artist: String {
        return artistName ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
}
