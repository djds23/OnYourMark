//
//  AddMarkViewController.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import CloudKit

class AddMarkViewController: UIViewController {
  
  let stackView: UIStackView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.axis = .vertical
    $0.alignment = .center
    $0.distribution = .fill
    $0.spacing = 10
    return $0
  }(UIStackView())
  
  let markNameTextField: UITextField = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.textContentType = UITextContentType.name
    $0.placeholder = "My Favorite feed"
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.layer.borderColor = UIColor.darkGray.cgColor
    $0.layer.borderWidth = 1
    return $0
  }(UITextField())

  let markURLTextField: UITextField = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.textContentType = UITextContentType.URL
    $0.placeholder = "www.example.com"
    $0.setContentHuggingPriority(.required, for: .vertical)
    $0.layer.borderColor = UIColor.darkGray.cgColor
    $0.layer.borderWidth = 1
    return $0
  }(UITextField())

  let acceptButton: UIButton = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.setTitle("Add Mark", for: .normal)
    return $0
  }(UIButton())
  
  let activityIndicator: UIActivityIndicatorView = {
    $0.isHidden = true
    return $0
  }(UIActivityIndicatorView())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    navigationItem.title = "Add Mark"
    view.addSubview(stackView)

    let topC = stackView.layoutMarginsGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
    topC.identifier = "top constraint"
    topC.isActive = true

    let botC = stackView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10)
    botC.identifier = "bot constraint"
    botC.isActive = true

    let leadC = stackView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
    leadC.identifier = "lead constraint"
    leadC.isActive = true
    
    let trailC = stackView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 10)
    trailC.identifier = "trail constraint"
    trailC.isActive = true
    
    acceptButton.setTitleColor(view.tintColor, for: .normal)
    acceptButton.addTarget(self, action: #selector(AddMarkViewController.saveMark(_:)), for: .touchUpInside)

    let innerViews = [
      activityIndicator,
      markNameTextField,
      markURLTextField,
      acceptButton
    ]

    innerViews.forEach(stackView.addArrangedSubview)
  }
  
  func isBusy(_ busy: Bool) {
    stackView.arrangedSubviews.forEach { (view) in
      if view == activityIndicator {
        if busy {
          activityIndicator.startAnimating()
        } else {
          activityIndicator.stopAnimating()
        }
        view.isHidden = !busy
      } else {
        view.isHidden = busy
      }
    }
  }
  @objc func saveMark(_ sender: Any?) {
    guard
      let name = self.markNameTextField.text,
      let urlText = self.markURLTextField.text,
      let url = URL(string: urlText)
    else {
      return
    }
    isBusy(true)
    let mark = Mark(name: name, url: url)
    Persitence.default.set(mark: mark) { [weak self] success in
      self?.isBusy(false)
    }
  }
}
