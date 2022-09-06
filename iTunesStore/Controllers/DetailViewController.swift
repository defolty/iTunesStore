//
//  DetailViewController.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 06.09.2022.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
    
    ///# Вызывается для загрузки `viewController'a` из раскадровки
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
