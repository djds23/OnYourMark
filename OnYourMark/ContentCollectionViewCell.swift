//
//  ContentCollectionViewCell.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

class ContentCollectionViewCell: UICollectionViewCell {
  static var identifier: String {
    return "ContentCollectionViewCell"
  }

  static var reuseIdentifier: String? {
    return identifier
  }

  var titleText: String? {
    didSet {
      if titleLabel != nil {
        titleLabel.text = titleText
      }
    }
  }

  var subtitleText: String? {
    didSet {
      if subtitleLabel != nil {
        subtitleLabel.text = subtitleText
      }
    }
  }

  @IBOutlet weak var titleLabel: UILabel! {
    didSet {
      if titleLabel != nil {
        titleLabel.text = titleText
      }
    }
  }
  @IBOutlet weak var subtitleLabel: UILabel! {
    didSet {
      if subtitleLabel != nil {
        subtitleLabel.text = subtitleText
      }
    }
  }
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
