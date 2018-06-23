//
//  MarksViewController.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MarksViewController: UIViewController {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var marks = [Mark]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  var disposeBag = DisposeBag()
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    let addMark = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(MarksViewController.addMark(_:))
    )
    navigationItem.title = "Marks"
    navigationItem.rightBarButtonItems = [ addMark ]
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
    fetch()
  }
  
  func fetch() {
    collectionView.refreshControl?.beginRefreshing()
    Persitence.default.get { [weak self] getOperation in
      switch getOperation {
      case .success(let marks):
        self?.marks = marks
      case .error:
        break
      }
      self?.collectionView.refreshControl?.endRefreshing()
    }
  }

  @objc func handleRefresh(_ sender: Any?) {
    fetch()
  }

  @objc func addMark(_ sender: Any?) {
  navigationController?.pushViewController(AddMarkViewController(), animated: true)
  }
}

extension MarksViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return marks.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentCollectionViewCell", for: indexPath) as? ContentCollectionViewCell ?? ContentCollectionViewCell()
    cell.backgroundColor = .white
    let mark = marks[indexPath.row]
    cell.titleText = "\(mark.name) \(indexPath.row)"
    cell.subtitleText = mark.url.absoluteString
    return cell
  }
  
  func infoWasTappedFor(mark: Mark, indexPath: IndexPath) {
    let alertController = UIAlertController(title: "Delete Mark", message: "Delete this mark from the CLOUD!", preferredStyle: .alert)
    let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
      Persitence.default.delete(mark: mark, with: { [weak self] completed in
        if completed {
          DispatchQueue.main.async {
            self?.collectionView.reloadData()
          }
        }
      })
    }
    let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(delete)
    alertController.addAction(cancel)
    present(alertController, animated: true, completion: nil)
  }
}

extension MarksViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let mark = marks[indexPath.row]
    let viewModel = FeedViewModel(url: mark.url)
    let feedViewController = FeedViewController(viewModel: viewModel, title: mark.name)
    navigationController?.pushViewController(feedViewController, animated: true)
  }
}
