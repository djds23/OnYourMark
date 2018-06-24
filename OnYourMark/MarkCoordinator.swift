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
    let marksViewModel = MarksViewModel()
    let marksViewController = MarksViewController(viewModel: marksViewModel)
    marksViewController.delegate = self
    navController.pushViewController(marksViewController, animated: true)
    completion?()
  }
  
  func stop(completion: Completion?) {
    navController.popToRootViewController(animated: true)
    completion?()
  }
}

extension MarkCoordinator: MarksViewControllerDelegate {
  func marksViewController(_ marksViewController: MarksViewController, didSelect mark: Mark) {
    let viewModel = FeedViewModel(url: mark.url)
    let feedViewController = FeedViewController(viewModel: viewModel, title: mark.name)
    feedViewController.delegate = self
    navController.pushViewController(feedViewController, animated: true)
  }
  
  func marksViewControllerDidRequestNewMark(_ marksViewController: MarksViewController) {
    navController.pushViewController(AddMarkViewController(), animated: true)
  }
}

extension MarkCoordinator: FeedViewControllerDelegate {
  func feedViewController(_ feedViewController: FeedViewController, didRequestShareSheetFor feedItem: FeedItem, with sourceView: UIView?) {
    let activityViewController = UIActivityViewController(activityItems: [feedItem.url], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = sourceView
    activityViewController.popoverPresentationController?.sourceRect = sourceView?.frame ?? .zero
    navController.present(activityViewController, animated: true, completion: nil)
  }
}
