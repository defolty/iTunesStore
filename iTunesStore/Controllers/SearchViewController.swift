//
//  ViewController.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 02.09.2022.
//

import UIKit
 
// MARK: - SeachBar Setup

extension SearchViewController: UISearchBarDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!)
            
            ///# `shared` - общий экземпляр `URLSession`
            let session = URLSession.shared
            
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
                if let error = error as NSError?, error.code == -999 {
                    print("Failure! \(error)")
                    ///# Параметр ответа имеет тип данных `URLResponse`, но у него нет свойства для кода статуса.
                    ///# Поскольку вы используете протокол `HTTP`,
                    ///# то на самом деле вы получили объект `HTTPURLResponse`, подкласс `URLResponse`
                    ///# Поэтому сначала приведите его к нужному типу,
                    ///# а затем посмотрите на его свойство `statusCode` -
                    ///# вы будете считать задание успешным, только если его значение равно `200`
                } else if let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 {
                    ///# Это разворачивает опционал объект из параметра `data`
                    ///# затем вызывает `parse(data:)`
                    ///# чтобы превратить содержимое словаря в объекты `SearchResult`
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            ///# как только создана `dataTask`, нужно вызвать `resume()` для ее запуска.
            ///# Это отправит запрос на сервер в фоновом потоке.
            ///# Таким образом, приложение сразу же может продолжать работу - `URLSession` является асинхронным
            dataTask?.resume()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - TableView Setup

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.loadingCell,
                for: indexPath
            )
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(
                withIdentifier: Constants.nothingFoundCell,
                for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Constants.searchResultCell,
                for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(
                    format: "%@ (%@)",
                    searchResult.artist, searchResult.type
                )
            }
            return cell
        }
    }
}

// MARK: - SearchViewController

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var hasSearched = false
    private var isLoading = false
    private var dataTask: URLSessionDataTask?
    
    private var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        registerCells()
        setupTableView()
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
    
    private func iTunesURL(searchText: String) -> URL {
        ///# Для создания новой строки, в которой все специальные символы исключены, и вы используете эту строку для поискового термина
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed
        )!
        let urlString = String(
            format: "https://itunes.apple.com/search?term=%@&limit=200",
            encodedText
        )
        let url = URL(string: urlString)!
        return url
    }
    
    private func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error accessing the iTunes Store." + " Please try again.",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupTableView() {
        ///# Это указывает tableView добавить 64-точечное поле сверху - 20 точек для строки состояния и 44 точки для строки поиска.
        ///# Теперь первая строка всегда будет видна, а при прокрутке представления таблицы ячейки все равно попадают под строку поиска.
        tableView.contentInset = UIEdgeInsets(
            top: 64, left: 0,
            bottom: 0, right: 0
        )
    }
    
    private func registerCells() {
        var cellNib = UINib(
            nibName: Constants.searchResultCell,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.searchResultCell
        )
        cellNib = UINib(
            nibName: Constants.nothingFoundCell,
            bundle: nil
        )
        tableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.nothingFoundCell
        )
        cellNib = UINib(
            nibName: Constants.loadingCell,
            bundle: nil
        )
        tableView.register(
            cellNib, forCellReuseIdentifier:
                Constants.loadingCell
        )
    }
}

