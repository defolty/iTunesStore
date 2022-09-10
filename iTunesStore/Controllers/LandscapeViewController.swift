//
//  LandscapeViewController.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 09.09.2022.
//

import UIKit

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((
            scrollView.contentOffset.x + width / 2) / width
        )
        pageControl.currentPage = page
    }
}

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var searchResults = [SearchResult]()
    private var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        setupViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        pageControl.frame = CGRect(
            x: safeFrame.origin.x,
            y: safeFrame.size.height - pageControl.frame.size.height,
            width: safeFrame.size.width,
            height: pageControl.frame.size.height
        )
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
     
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 6
        var rowsPerPage = 3
        var itemWidth: CGFloat = 94
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 2
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            // 4-inch device
            break
            
        case 667:
            // 4.7-inch device
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            // 5.5-inch device
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            marginX = 0
            
        case 724:
            // iPhone X
            columnsPerPage = 8
            rowsPerPage = 3
            itemWidth = 90
            itemHeight = 98
            marginX = 2
            marginY = 29
            
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in searchResults.enumerated() {
            print(type(of: result)) // to delete
            ///# Создаём объект UIButton. В целях отладки даём каждой кнопке заголовок с индексом массива
            ///# Если в поиске есть 200 результатов, то в итоге у нас также должно быть 200 кнопок
            ///# Установка индекса на кнопку поможет в этом убедиться
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            button.setTitle("\(index)", for: .normal)
            ///# При создании кнопки вручную, всегда нужно установить её `frame`
            ///# Используя измерения, которые мы выяснили ранее, определить положение и размер кнопки
            ///# Все свойства `CGRect` - это `CGFloat`, но `row` - это `Int`
            ///# Нужно преобразовать `row` в `CGFloat`, прежде чем использовать его в вычислениях
            button.frame = CGRect(
                x: x + paddingHorz,
                y: marginY + CGFloat(row)*itemHeight + paddingVert,
                width: buttonWidth, height: buttonHeight
            )
            ///# Добавляем объект кнопки в `UIScrollView` в качестве `subview`.
            ///# После первых 18 или около того кнопок (в зависимости от размера экрана),
            ///# это помещает все последующие кнопки за пределы видимого диапазона представления прокрутки,
            ///# но в этом и заключается весь смысл
            scrollView.addSubview(button)
            ///# Мы используем переменные x и row для позиционирования кнопок, двигаясь сверху вниз (увеличивая ряд).
            ///# Когда мы достигли низа (row равен rowsPerPage), мы снова поднимаемся до строки 0 и переходим к следующему столбцу (увеличивая переменную column)
            ///# Когда столбец достигает конца экрана (равен columnsPerPage), мы сбрасываем его на 0 и добавляем оставшееся пространство к x (удвоенное значение X-margin)
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        // Scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height
        )
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
     
    private func setupViews() {
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        pageControl.numberOfPages = 0
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.scrollView.contentOffset = CGPoint(
                x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                y: 0
            )
        }, completion: nil)
    }
}
