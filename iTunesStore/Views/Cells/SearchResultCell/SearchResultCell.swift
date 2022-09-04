//
//  SearchResultCell.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 02.09.2022.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    var downloadTask: URLSessionDownloadTask?
    
    ///# Метод `awakeFromNib()` вызывается после загрузки объекта ячейки из `nib`,
    ///# но до добавления ячейки в табличное представление
    ///# !!! Вызывается через некоторое время после `init?(coder:)`
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSelectedView()
    }
    
    // MARK: - Public Methods
    
    func configure(for result: SearchResult) {
        nameLabel.text = result.name
        
        if result.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)",
                                          result.artist, result.type)
        }
        
        ///# Это указывает `UIImageView` загрузить изображение из `imageSmall` и поместить его в представление изображения ячейки.
        ///# Пока загружается реальное изображение, в представлении изображения отображается `placeholder` - та самая, из `nib` для этой ячейки
        artworkImageView.image = UIImage(named: "Placeholder")
        if let smallURL = URL(string: result.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
    }
    
    private func setupSelectedView() {
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(
            red: 20/255,
            green: 160/255,
            blue: 160/255,
            alpha: 0.5
        )
        selectedBackgroundView = selectedView
        artworkImageView.layer.cornerRadius = 8
    }
}
