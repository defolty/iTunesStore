//
//  GradientView.swift
//  iTunesStore
//
//  Created by Nikita Nesporov on 06.09.2022.
//

import UIKit

class GradientView: UIView {
    ///# В методах `init(frame:)` и `init?(coder:)` просто устанавливаем полностью прозрачный цвет фона.
    ///# Затем в `draw()` рисуем градиент поверх этого прозрачного фона так, чтобы он сливался с тем, что находится под ним.
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
     
/** Сначала создаём два массива, которые содержат "цветовые границы" для градиента.
    Первый цвет (0, 0, 0, 0, 0.3) - это черный цвет, который в основном прозрачен.
    Он располагается в месте 0 в градиенте, которое представляет собой центр экрана, поскольку будем рисовать круговой градиент.
    Второй цвет (0, 0, 0, 0, 0.7) также черный, но гораздо менее прозрачный, и располагается в позиции 1,
    которая представляет собой окружность круга градиента.
    Note: В `UIKit`, а также в `Core Graphics`, цвета и значения непрозрачности не идут от 0 до 255, а являются дробными значениями от 0,0 до 1,0.
    Значения 0 и 1 из массива `locations` представляют собой проценты: 0% и 100%, соответственно.
    Если у нас более двух цветов, вы можете указать проценты того, где в градиенте вы хотите разместить эти цвета. */
    override func draw(_ rect: CGRect) {
        let components: [CGFloat] = [ 0, 0, 0, 0.3, 0, 0, 0, 0.7 ]
        let locations: [CGFloat] = [ 0, 1 ]
        // 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace,
                                  colorComponents: components,
                                  locations: locations, count: 2)
        // 3
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y : y)
        let radius = max(x, y)
        // 4
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(
            gradient!,
            startCenter: centerPoint, startRadius: 0,
            endCenter: centerPoint, endRadius: radius,
            options: .drawsAfterEndLocation
        )
    }
}
