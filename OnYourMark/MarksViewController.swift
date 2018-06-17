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
  var marks = [Mark]()
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
    Persitence.default.get { newMarks in
      self.marks = newMarks
      self.collectionView.refreshControl?.endRefreshing()
      self.collectionView.reloadData()
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
    if cell.moreStackView.arrangedSubviews.count == 0 {
      let moreButton = UIButton(type: .detailDisclosure)
      moreButton.rx.tap.asObservable().subscribe(onNext: { (tap) in
        print("tapp that")
      }).disposed(by: disposeBag)
      cell.moreStackView.addArrangedSubview(moreButton)
    }
    return cell
  }
}

extension MarksViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let feedViewController = FeedViewController(nibName: nil, bundle: nil)
    let mark = marks[indexPath.row]
    feedViewController.set(mark: mark)
    navigationController?.pushViewController(feedViewController, animated: true)
  }
}
