//
//  GoSearchViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/30/26.
//

import UIKit

import Toast
import Alamofire

final class GoSearchViewController: UIViewController {

    let searchBarController = UISearchController(searchResultsController: nil)

    var onTextFilled: ((String) -> Void)?
    var onCloseButtonTapped: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureLayout()
        configureView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            print("0.1초뒤 리스폰더 설정")
            self.searchBarController.searchBar.becomeFirstResponder()
        }
    }


    private func configureSearchController() {
        navigationItem.searchController = searchBarController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = "키워드 검색"
        searchBarController.hidesNavigationBarDuringPresentation = false
    }
}

extension GoSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        onCloseButtonTapped?()
        navigationController?.popViewController(animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let validated = validateText(searchBar.text) else {
            view.makeToast("2글자 이상 입력해주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.becomeFirstResponder()
            }
            return
        }

        onTextFilled?(validated)
        navigationController?.popViewController(animated: true)
    }

    // nil 값이면 벨리데이트 실패, 값이 있다면 제대로 리턴 된 것임
    private func validateText(_ text: String?) -> String? {
        guard let searchText = text,
              !searchText.isEmpty else { return nil }

        let withoutSpacing = searchText.replacingOccurrences(of: " ", with: "")
        if withoutSpacing.count < 2 { return nil }

        return withoutSpacing.lowercased()
    }
}

extension GoSearchViewController: BasicViewProtocol {
    func configureHierarchy() {
        print(#function)
    }

    func configureLayout() {
        print(#function)
    }

    func configureView() {
        view.backgroundColor = .white
        configureSearchController()
    }
}
