//
//  MarksViewController.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit


class MarksViewController: UIViewController {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  var marks = [Mark]()

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
  collectionView.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = .clear
    fetch()
  }
  
  func fetch() {
    Persitence.default.get { newMarks in
      self.marks = newMarks
      self.collectionView.reloadData()
    }
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
    let mark = marks[indexPath.row]
    cell.titleLabel.text = mark.name
    cell.bottomLabel.text = mark.url.absoluteString
    return cell
  }
}

extension MarksViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 100)
  }
}
