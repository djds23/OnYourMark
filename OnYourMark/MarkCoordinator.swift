//
//  MarkCoordinator.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/23/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
typealias Completion = () -> Void
protocol Coordinator {
  func start(completion: Completion?)
  func stop(completion: Completion?)
}

class MarkCoordinator: NSObject, Coordinator {

  let navController: UINavigationController
  init(navController: UINavigationController) {
    self.navController = navController
  }

  func start(completion: Completion?) {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let rootVC = storyboard.instantiateInitialViewController()!
    navController.pushViewController(rootVC, animated: true)
    completion?()
  }
  
  func stop(completion: Completion?) {
    navController.popToRootViewController(animated: true)
    completion?()
  }
}

