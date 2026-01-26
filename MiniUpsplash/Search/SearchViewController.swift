//
//  SearchViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 1/26/26.
//

import UIKit

import SnapKit
import Toast

final class SearchViewController: UIViewController {

    private let searchBarController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard var searchText = searchBar.text,
              !searchText.isEmpty,
              searchText.replacingOccurrences(of: " ", with: "").count > 1 else {
            // TODO: - Alert
            view.makeToast("2글자 이상 입력해주세요")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.becomeFirstResponder()
            }
            return
        }
        print(#function, searchBar.text!)
    }
}

extension SearchViewController: BasicViewProtocol {
    func configureHierarchy() {
    }
    
    func configureLayout() {
    }
    
    func configureView() {
        navigationItem.title = "SEARCH PHOTO"
        view.backgroundColor = .white
        configureSearchController()
    }

    private func configureSearchController() {
        navigationItem.searchController = searchBarController
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.preferredSearchBarPlacement = .stacked
        searchBarController.searchBar.delegate = self
        searchBarController.searchBar.placeholder = "키워드 검색"
        searchBarController.hidesNavigationBarDuringPresentation = false
    }
}
