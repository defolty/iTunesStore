//
//  Delete.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 10.09.2022.
//

/*
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
 */
