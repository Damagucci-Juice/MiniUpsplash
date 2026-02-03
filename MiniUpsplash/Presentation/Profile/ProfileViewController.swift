//
//  ProfileViewController.swift
//  MiniUpsplash
//
//  Created by Gucci on 2/3/26.
//

import UIKit

import SnapKit
import Toast

enum BirthdayError: Error, LocalizedError {
    case invalidYear
    case invalidMonth
    case invalidDay
    case isNotNumber

    var errorDescription: String? {
        switch self {
        case .invalidYear:
            return "1930~2026 사이의 숫자를 입력해주세요"
        case .invalidMonth:
            return "1~12 사이의 숫자를 입력해주세요"
        case .invalidDay:
            return "1~31 사이의 숫자를 입력해주세요"
        case .isNotNumber:
            return "숫자를 입력해주세요"
        }
    }
}

final class ProfileViewController: UIViewController {

    private let yearTextField = {
        let tf = UITextField()
        tf.placeholder = "태어난 해를 입력해주세요"
        tf.borderStyle = .bezel
        tf.keyboardType = .numberPad
        tf.tag = 0
        return tf
    }()

    private let monthTextField = {
        let tf = UITextField()
        tf.placeholder = "태어난 월을 입력해주세요"
        tf.borderStyle = .bezel
        tf.keyboardType = .numberPad
        tf.tag = 1
        return tf
    }()

    private let dayTextField = {
        let tf = UITextField()
        tf.placeholder = "태어난 일을 입력해주세요"
        tf.borderStyle = .bezel
        tf.keyboardType = .numberPad
        tf.tag = 2
        return tf
    }()

    private lazy var confirmationButton = {
        let button = UIButton()
        button.configuration = .bordered()
        button.setTitle("확인", for: .normal)
        button.addTarget(self, action: #selector(confirmationButtonTapped), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureView()
    }

    @objc private func confirmationButtonTapped() {
        do {
            guard try validateContent(yearTextField.tag),
                  try validateContent(monthTextField.tag),
                  try validateContent(dayTextField.tag) else { return }

            let year    = Int(yearTextField.text!)!
            let month   = Int(monthTextField.text!)!
            let day     = Int(dayTextField.text!)!

            var dateComponent = DateComponents()
            dateComponent.year = year
            dateComponent.month = month
            dateComponent.day = day
            if dateComponent.isValidDate {
                view.makeToast("\(year)년 \(month)월 \(day)일에\n태어나셨군요!", position: .top)
                confirmationButton.setTitle("효과적인 생일입니다!", for: .normal)
            } else {
                view.makeToast("\(year)년 \(month)월 \(day)일은\n없는 날입니다. 정신차리세요!", position: .top)
            }

        } catch {
            switch error {
            case .invalidYear:
                yearTextField.becomeFirstResponder()
            case .invalidMonth:
                monthTextField.becomeFirstResponder()
            case .invalidDay:
                dayTextField.becomeFirstResponder()
            default:
                view.makeToast(error.errorDescription ?? "")
            }
            view.makeToast(error.errorDescription ?? "")

        }
    }

    @objc private func textFieldDidReturn(_ tf: UITextField) {
        do {
            if try validateContent(tf.tag) {
                renderFocus(tf.tag)
            }
        } catch {
            view.makeToast(error.errorDescription ?? "알 수 없는 에러", position: .top)
        }
    }

    private func renderFocus(_ tfTag: Int) {
        if tfTag == 0 {
            monthTextField.becomeFirstResponder()
        } else if tfTag == 1 {
            dayTextField.becomeFirstResponder()
        } else if tfTag == 2 {
            confirmationButtonTapped()
        }
    }

    private func validateContent(_ tf: Int) throws(BirthdayError) -> Bool {
        switch tf {
        case 0:
            guard let text = yearTextField.text,
                  let year = Int(text) else { throw .isNotNumber }
            if 1930 <= year, year < 2027 {
                return true
            } else {
                throw .invalidYear
            }
        case 1:
            // month
            guard let text = monthTextField.text,
                  let month = Int(text) else { throw .isNotNumber }
            if 1 <= month, month < 13 {
                return true
            } else {
                throw .invalidMonth
            }
        default:
            guard let text = dayTextField.text,
                  let day = Int(text) else { throw .isNotNumber }
            if 1..<32 ~= day {
                // TODO: - 2월, 윤달, 30, 31
                return true
            } else {
                throw .invalidDay
            }
        }
    }

    @objc private func backgroundTapped() {
        view.endEditing(true)
    }
}

extension ProfileViewController: BasicViewProtocol {
    func configureHierarchy() {
        [yearTextField, monthTextField, dayTextField, confirmationButton].forEach {
            view.addSubview($0)
        }
    }
    
    func configureLayout() {
        yearTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.height.equalTo(44)
        }

        monthTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.top.equalTo(yearTextField.snp.bottom).offset(40)
            make.height.equalTo(44)
        }

        dayTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.top.equalTo(monthTextField.snp.bottom).offset(40)
            make.height.equalTo(44)
        }

        confirmationButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
            make.top.equalTo(dayTextField.snp.bottom).offset(40)
            make.height.equalTo(44)
        }
    }
    
    func configureView() {
        navigationItem.title = "Birthday"
        view.backgroundColor = .white
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(viewTapGesture)

        [yearTextField, monthTextField, dayTextField].forEach {
            $0.addTarget(self, action: #selector(textFieldDidReturn), for: .editingDidEndOnExit)
        }
    }
}
