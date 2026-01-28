//
//  UILabel+ext.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/27/26.
//

import UIKit

extension UILabel {
    func setSectionHeader() {
        font = .boldSystemFont(ofSize: 22)
        textColor = .black
        numberOfLines = 0
        textAlignment = .left
    }

    // username : Brayden Prato
    func setBody() {
        self.font = .systemFont(ofSize: 14, weight: .regular)
        self.textColor = .black
        self.numberOfLines = 1
    }

    // created at : 2024년 7월 3일 게시됨
    func setCaption() {
        self.font = .boldSystemFont(ofSize: 12)
        self.textColor = .black
        self.numberOfLines = 1
    }

    // Detail: 정보, 차트
    func setHeader() {
        self.font = .boldSystemFont(ofSize: 20)
        self.textColor = .black
        self.numberOfLines = 1
    }

    // Detail: 크기, 조회수, 다운로드
    func setSubHeader() {
        self.font = .boldSystemFont(ofSize: 14)
        self.textColor = .black
        self.numberOfLines = 1
    }
}
