//
//  Search.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 10.09.2022.
//

import Foundation

class Search {
    
    private(set) var state: State = .notSearchedYet /// read only
    private var dataTask: URLSessionDataTask? = nil
    typealias SearchComplete = (Bool) -> Void
    
    enum State {
        case notSearchedYet /// also as error
        case loading
        case noResults
        case results([SearchResult])
        ///# associated value — an array of `SearchResult` objects
        ///# Этот массив имеет значение только в случае успешного поиска.
        ///# Во всех остальных случаях результатов поиска нет, и массив пуст.
        ///# Сделав его associated, мы будем иметь доступ к этому массиву только тогда,
        ///# когда `Search` находится в состоянии `.results`
        ///# В других состояниях массив просто не существует
    }
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 4
        
        var type:String {
          let kind = self.kind ?? "audiobook"
          switch kind {
          case "album":
            return NSLocalizedString("Album",
                            comment: "Localized kind: Album")
          case "audiobook":
            return NSLocalizedString("Audio Book",
                            comment: "Localized kind: Audio Book")
          case "book":
            return NSLocalizedString("Book",
                            comment: "Localized kind: Book")
          case "ebook":
            return NSLocalizedString("E-Book",
                            comment: "Localized kind: E-Book")
          case "feature-movie":
            return NSLocalizedString("Movie",
                            comment: "Localized kind: Feature Movie")
          case "music-video":
            return NSLocalizedString("Music Video",
                            comment: "Localized kind: Music Video")
          case "podcast":
            return NSLocalizedString("Podcast",
                            comment: "Localized kind: Podcast")
          case "software":
            return NSLocalizedString("App",
                            comment: "Localized kind: Software")
          case "song":
            return NSLocalizedString("Song",
                            comment: "Localized kind: Song")
          case "tv-episode":
            return NSLocalizedString("TV Episode",
                            comment: "Localized kind: TV Episode")
          default:
            return kind
          }
        }
    }
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            state = .loading
            let url = iTunesURL(searchText: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                var success = false
                var newState = State.notSearchedYet
                
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }
                
                DispatchQueue.main.async {
                    self.state = newState
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            ///# Объект `JSONDecoder` для преобразования данных ответа от сервера во временный объект `ResultArray`
            ///# Из которого извлекаем свойство `results` если всё ок
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
        
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed
        )!
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)"
        
        let url = URL(string: urlString)!
        
        return url
    }
}
