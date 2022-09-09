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
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            searchTableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            
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
                            self.searchTableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.searchTableView.reloadData()
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

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Constants.detailVCIdentifier, sender: indexPath)
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
            cell.configure(for: searchResult)
            return cell
        }
    }
}

// MARK: - SearchViewController

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var hasSearched = false
    private var isLoading = false
    private var dataTask: URLSessionDataTask?
    var landscapeVC: LandscapeViewController?
    
    private var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        registerCells()
        setupTableView()
    }
    
    ///# The horizontal/vertical size class
    ///# The display scale — is this a Retina screen or not?
    ///# The user interface idiom — is this an iPhone or iPad?
    ///# The preferred Dynamic Type font size
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            fatalError()
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        ///# Не должно происходить так, чтобы приложение создавало второе `view landscape`, когда другое уже представлено
        guard landscapeVC == nil else {
            return
        }
        landscapeVC = storyboard!.instantiateViewController(
            withIdentifier: Constants.landscapeVCIdentifier
        ) as? LandscapeViewController
        if let controller = landscapeVC {
            ///# Определяем размер и положение нового контроллера представления.
            ///# В результате `view LandscapeViewController` станет таким же большим,
            ///# как и контроллер `SearchViewController`, занимая весь экран
            ///# `frame` - это прямоугольник, который описывает положение и размер представления с точки зрения его `superview`
            ///# Чтобы переместить `view` в его конечное положение и размер, обычно устанавливается его `frame`
            ///# `bounds` - это тоже прямоугольник, но видимый изнутри представления
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            ///# Поскольку представление `SearchViewController` является здесь `superview`,
            ///# `frame` ландшафтного представления должна быть сделана равной `bounds SearchViewController`
            view.addSubview(controller.view)
            addChild(controller)
            
            ///# `animate(alongsideTransition:completion:)` принимает два закрытия:
            ///# первое - для самой анимации,
            ///# второе - `completion`, который вызывается после завершения анимации
            ///# и который дает вам возможность отложить вызов didMove(toParent:) до окончания анимации
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParent: self)
            })
            ///# Не удаляем `view` и `vc`, пока анимация не будет полностью завершена
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            ///# Сначала `willMove(toParent:)`, чтобы сообщить контроллеру представления
            ///# что он покидает иерархию `viewController's` и у него больше нет родителя
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParent()
                self.landscapeVC = nil
            })
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
    
    private func iTunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed
        )!
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)"
        
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
    
    private func registerCells() {
        var cellNib = UINib(
            nibName: Constants.searchResultCell,
            bundle: nil
        )
        searchTableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.searchResultCell
        )
        cellNib = UINib(
            nibName: Constants.nothingFoundCell,
            bundle: nil
        )
        searchTableView.register(
            cellNib,
            forCellReuseIdentifier: Constants.nothingFoundCell
        )
        cellNib = UINib(
            nibName: Constants.loadingCell,
            bundle: nil
        )
        searchTableView.register(
            cellNib, forCellReuseIdentifier:
                Constants.loadingCell
        )
    }
    
    private func setupTableView() {
        ///# Это указывает tableView добавить 64-точечное поле сверху - 20 точек для строки состояния и 44 точки для строки поиска.
        ///# Теперь первая строка всегда будет видна, а при прокрутке представления таблицы ячейки все равно попадают под строку поиска.
        searchTableView.contentInset = UIEdgeInsets(
            top: 108, left: 0,
            bottom: 0, right: 0
        )
    }
    
    private func setupSegmentedControl() {
        let segmentColor = UIColor(red: 10/255, green: 80/255, blue: 80/255, alpha: 1)
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: segmentColor]
        segmentedControl.selectedSegmentTintColor = segmentColor
        segmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        segmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .highlighted)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.detailVCIdentifier {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
    // MARK: - Action's

    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
}

