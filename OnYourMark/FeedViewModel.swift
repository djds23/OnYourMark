//
//  FeedViewModel.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/17/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import RxSwift

enum FeedState {
  case none
  case feed([FeedItem])
}

struct FeedItem {
  let title: String
  let url: URL
}

func parsedFeed(document: XMLElement?) -> [FeedItem]? {
  return document?.findChildrenBy(names: ["item", "entry"]).compactMap({ (child) -> FeedItem? in

    guard let titleElement = child.findChildBy(name: "title") else {
      return nil
    }
    guard let title = titleElement.body else {
      return nil
    }
    guard let linkElement = child.findChildBy(name: "link") else {
      return nil
    }
    guard let url = urlFor(link: linkElement) else {
      return nil
    }
    return FeedItem(title: title, url: url)
  })
}

func urlFor(link: XMLElement) -> URL? {
  let url: URL?
  if let body = link.body {
    url = URL(string: body)
  } else if let href = link.attributes["href"] {
    url = URL(string: href)
  } else {
    url = nil
  }
  return url
}

class FeedViewModel {
  var state: Observable<FeedState> {
    return subject.asObservable()
  }
  private var parsedDocument: ParsedXMLDocument?
  private var document: XMLElement? {
    didSet {
      if let feed = parsedFeed(document: document) {
        subject.onNext(.feed(feed))
      } else {
        subject.onNext(.none)
      }
    }
  }
  private let subject = BehaviorSubject<FeedState>(value: .none)

  func fetch(url: URL) {
    if parsedDocument == nil {
      let parser = XMLParser(contentsOf: url)
      parsedDocument = ParsedXMLDocument(parser: parser)
      parsedDocument?.delegate = self
      parsedDocument?.parse()
    }
  }
}

extension FeedViewModel: ParsedXMLDocumentDelegate {
  func parsedXMLDocument(didUpdate document: XMLElement) {
    self.document = document
  }
}