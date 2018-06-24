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

protocol MarksViewControllerDelegate: class {
  func marksViewController(_ marksViewController: MarksViewController, didSelect mark: Mark)
  func marksViewControllerDidRequestNewMark(_ marksViewController: MarksViewController)
}

class MarksViewController: UIViewController {
  let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

  var marks = [Mark]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }

  var loading = false {
    didSet {
      DispatchQueue.main.async { [weak self] in
        if (self?.loading ?? false) {
          self?.collectionView.refreshControl?.beginRefreshing()
        } else {
          self?.collectionView.refreshControl?.endRefreshing()
        }
      }
    }
  }

  let disposeBag = DisposeBag()
  let viewModel: MarksViewModel
  weak var delegate: MarksViewControllerDelegate?
  
  init(viewModel: MarksViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
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
    viewModel.marksObserable.subscribe(onNext: { [weak self] (marks) in
      self?.marks = marks
      self?.loading = false
    }).disposed(by: disposeBag)
    fetch()
  }

  @objc func handleRefresh(_ sender: Any?) {
    fetch()
  }

  @objc func addMark(_ sender: Any?) {
    delegate?.marksViewControllerDidRequestNewMark(self)
  }
  
  func fetch() {
    loading = true
    viewModel.fetch()
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
    cell.titleText = mark.name
    cell.subtitleText = mark.url.absoluteString
    return cell
  }
}

extension MarksViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 60)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let mark = marks[indexPath.row]
    delegate?.marksViewController(self, didSelect: mark)
  }
}
