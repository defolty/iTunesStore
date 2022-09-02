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
    
    ///# Метод `awakeFromNib()` вызывается после загрузки объекта ячейки из `nib`,
    ///# но до добавления ячейки в табличное представление
    ///# !!! Вызывается через некоторое время после `init?(coder:)`
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupSelectedView()
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
    }
}
