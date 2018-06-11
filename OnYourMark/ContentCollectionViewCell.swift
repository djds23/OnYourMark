//
//  ContentCollectionViewCell.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
  var didUpdateConstraints = false
  let titleLabel: UILabel = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.numberOfLines = 0
    $0.setContentHuggingPriority(.required, for: .vertical)
    return $0
  }(UILabel())
  let bottomLabel: UILabel = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.numberOfLines = 0
    $0.setContentHuggingPriority(.required, for: .vertical)
    return $0
  }(UILabel())

  let stackView: UIStackView = {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.axis = .vertical
    $0.alignment = .leading
    $0.distribution = .fill
    $0.spacing = 10
    return $0
  }(UIStackView())

  override func updateConstraints() {
    if !didUpdateConstraints {
      translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(stackView)
      let topC = stackView.layoutMarginsGuide.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 0)
      topC.identifier = "top constraint"
      topC.isActive = true
      
      let botC = stackView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: 0)
      botC.identifier = "bot constraint"
      botC.isActive = true
      
      let leadC = stackView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 0)
      leadC.identifier = "lead constraint"
      leadC.isActive = true
      
      let trailC = stackView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: 0)
      trailC.identifier = "trail constraint"
      trailC.isActive = true
      let innerViews = [
        titleLabel,
        bottomLabel,
        UIView()
      ]
      innerViews.forEach(stackView.addArrangedSubview)
    }
    didUpdateConstraints = true
  }
}
