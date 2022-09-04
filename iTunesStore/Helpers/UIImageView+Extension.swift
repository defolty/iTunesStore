//
//  UIImageView+Extension.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 05.09.2022.
//

import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        ///# Похоже на `dataTask`, но она сохраняет загруженный файл во временном месте на диске, а не в памяти.
        let downloadTask = session.downloadTask(
            with: url,
            completionHandler: { [weak self] url, response, error in
                ///# Внутри `complitionHandler'a` для `downloadTask` дается `URL`,
                ///# по которому можно найти загруженный файл - этот `URL` указывает на локальный файл, а не на интернет-адрес
                if error == nil, let url = url,
                    ///# С помощью этого локального `URL` можем загрузить файл в объект `Data`
                    ///# а затем создать из него изображение.
                    ///# Возможно, что создание `UIImage` завершится неудачей,
                    ///# например, если то, что вы загрузили, было не действительным изображением,
                    ///# а страницей 404 или чем-то еще неожиданным
                    let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    ///# `[weak self]`, где `self` теперь ссылается на `UIImageView`
                    ///# Внутри `DispatchQueue.main.async` нужно проверить,
                    ///# существует ли еще `self` и если нет, то больше нет `UIImageView` для установки изображения
                    DispatchQueue.main.async {
                        if let weakSelf = self {
                            weakSelf.image = image
                        }
                    }
                }
            })
        downloadTask.resume()
        return downloadTask
    }
}
