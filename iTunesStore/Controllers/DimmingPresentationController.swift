//
//  DimmingPresentationController.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 06.09.2022.
//

import UIKit

///# Стандартный класс `UIPresentationController` содержит всю логику для отображения новых контроллеров представления.
///# `UIPresentationController` - это объект, который "управляет" представлением чего-либо
class DimmingPresentationController: UIPresentationController {
    
    lazy var dimmingView = GradientView(frame: CGRect.zero)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, at: 0)
    }
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
}
