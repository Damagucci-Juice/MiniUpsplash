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

    var onColorButtonTapped: (ColorParam) -> Void = { _ in }

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
        // TODO: - 이걸 끄고 켤 수 있게 할 때마다 네트워크 호출을 다시 하는게 맞을까?
        /// 맞다: 왜냐면 끄는거 자체가 하나의 API 요청으로 볼 수 있음
        /// 아니다: 요청을 원한다면 다른 버튼을 누르면 된다
        /// 내생각: 막아 놨을 때 어색했다. 끄는 것 자체도 API 요청으로 봐야할 것이다.
        isSelected.toggle()
        onColorButtonTapped(colorParam)
    }

    func configureButton() {
        self.setTitle(self.colorParam.paramValue.capitalized, for: .normal)
        self.setImage(UIImage(systemName: "circle.fill")?.withTintColor(UIColor(hex: self.colorParam.hex)!,
                                                                        renderingMode: .alwaysOriginal), for: .normal)
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
                btn.configuration?.baseBackgroundColor = .lightGray
                btn.configuration?.baseForegroundColor = .black
            default: break
            }
        }
    }
}
