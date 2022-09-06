//
//  DetailViewController.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 06.09.2022.
//

import UIKit
 
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    ///# Методы из этого протокола делегата сообщают `UIKit`, какие объекты он должен использовать для
    ///# выполнения перехода к контроллеру детального представления.
    ///# Теперь он будет использовать новый класс `DimmingPresentationController`
    ///# вместо стандартного контроллера представления.
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
     
    override func viewDidLoad() {
        super.viewDidLoad()
 
        view.tintColor = UIColor(red: 20/255, green: 160/225, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 12
    }
    
    ///# Вызывается для загрузки `viewController'a` из раскадровки
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
 
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
