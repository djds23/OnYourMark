//
//  MarkRecordType.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

enum MarkRecordType {
  case feed
  
  func asType() -> String {
    switch self {
    case .feed:
      return "feed"
    }
  }
}
