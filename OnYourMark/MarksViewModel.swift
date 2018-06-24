//
//  MarksViewModel.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/23/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import RxSwift

class MarksViewModel {

  var marksObserable: Observable<[Mark]> {
    return marksSubject.asObservable()
  }

  private var marksSubject = BehaviorSubject<[Mark]>(value: [])
  func fetch() {
    Persitence.default.get { [weak self] getOperation in
      guard let strongSelf = self else {
        return
      }
      switch getOperation {
      case .success(let marks):
        strongSelf.marksSubject.onNext(marks)
      case .error:
        strongSelf.marksSubject.onNext([])
      }
    }
  }
}
