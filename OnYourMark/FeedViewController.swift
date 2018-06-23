//
//  FeedViewController.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/11/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift

class FeedViewController: UIViewController {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var feedItems = [FeedItem]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }

  required init(viewModel: FeedViewModel, title: String) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    navigationItem.title = title
    viewModel.fetch()
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let viewModel: FeedViewModel
  let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    collectionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    collectionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    collectionView.register(
      UINib(nibName: "ContentCollectionViewCell", bundle: .main),
      forCellWithReuseIdentifier: ContentCollectionViewCell.identifier
    )
    collectionView.refreshControl = UIRefreshControl(frame: .zero)
    collectionView.refreshControl?.addTarget(
      self,
      action:
      #selector(MarksViewController.handleRefresh(_:)),
      for: UIControlEvents.valueChanged
    )
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .clear
    view.backgroundColor = .white
    listen()
  }
  
  func listen() {
    viewModel.state.subscribe { [weak self] (state) in
      switch state {
      case .next(let feedState):
        self?.mapStateToFeedItems(feedState)
      default:
        self?.feedItems = []
      }
    }.disposed(by: disposeBag)
  }
  
  func mapStateToFeedItems(_ feedState: FeedState) {
    switch feedState {
    case .needsFetch:
      feedItems = []
    case .feed(let items):
      feedItems = items
    }
  }

  @objc func handleRefresh(_ sender: Any?) {
    collectionView.refreshControl?.beginRefreshing()
    collectionView.refreshControl?.endRefreshing()
    collectionView.reloadData()
  }
}

extension FeedViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feedItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as? ContentCollectionViewCell ?? ContentCollectionViewCell()
    let item = feedItems[indexPath.row]
    cell.titleText = item.title
    cell.subtitleText = item.url.absoluteString
    return cell
  }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = feedItems[indexPath.row]
    let cellForIndex = collectionView.cellForItem(at: indexPath)
    let activityViewController = UIActivityViewController(activityItems: [item.url], applicationActivities: nil)
    activityViewController.popoverPresentationController?.sourceView = cellForIndex?.contentView
    activityViewController.popoverPresentationController?.sourceRect = cellForIndex?.contentView.frame ?? .zero
    present(activityViewController, animated: true, completion: nil)
  }
}
