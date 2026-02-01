//
//  ColorFilterView.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

import SnapKit

final class ColorFilterButton: UIButton {
    private(set) var colorParam: ColorParam

    var onColorButtonTapped: (ColorParam?) -> Void = { _ in }

    init(colorParam: ColorParam) {
        self.colorParam = colorParam
        super.init(frame: .zero)
        self.configureButton()
        self.addTarget(self, action: #selector(colorFilterTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func colorFilterTapped() {
        isSelected.toggle()
        onColorButtonTapped(isSelected ? colorParam : nil)
    }

    func configureButton() {
        self.setTitle(colorParam.text, for: .normal)
        self.setImage(colorParam.circleImage, for: .normal)
        var buttonConfig = UIButton.Configuration.bordered()

        buttonConfig.titleAlignment = .center
        buttonConfig.imagePlacement = .leading
        buttonConfig.imagePadding = 4
        self.configuration = buttonConfig
        self.configurationUpdateHandler = { btn in
            switch btn.state {
            case .selected:
                btn.configuration?.baseBackgroundColor = .tintColor
                btn.configuration?.baseForegroundColor = .systemOrange
            case .normal:
                btn.configuration?.baseBackgroundColor = .systemGray6
                btn.configuration?.baseForegroundColor = .black
            default: break
            }
        }
    }
}
