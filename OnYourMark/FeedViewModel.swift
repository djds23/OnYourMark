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

func parsedFeed(document: FrozenElement?) -> [FeedItem]? {
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

func urlFor(link: FrozenElement) -> URL? {
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

  private let url: URL?
  private let queue = DispatchQueue(
    label: "feedViewModelBackgroundQueue",
    qos: DispatchQoS.userInitiated
  )
  private let feedCache: FeedCache
  private var document: FrozenElement? {
    didSet {
      if let feed = parsedFeed(document: document) {
        subject.onNext(.feed(feed))
      } else {
        subject.onNext(.none)
      }
    }
  }

  init(url: URL) {
    self.url = url
    feedCache = FeedCache(url: url)
  }

  private let subject = BehaviorSubject<FeedState>(value: .none)
  func fetch() {
    queue.async { [weak self] in
      guard let strongSelf = self else { return }
      guard strongSelf.parsedDocument == nil else { return }
      guard let url = strongSelf.url else { return }
      let parser = XMLParser(contentsOf: url)
      strongSelf.parsedDocument = ParsedXMLDocument(parser: parser)
      strongSelf.parsedDocument?.delegate = strongSelf
      strongSelf.parsedDocument?.parse()
    }
  }
}

extension FeedViewModel: ParsedXMLDocumentDelegate {
  func parsedXMLDocument(error: XMLParseError) {
    self.document = self.feedCache.fetch()
  }
  
  func parsedXMLDocument(didUpdate document: FrozenElement) {
    self.document = document
    feedCache.cache(document: document)
  }
}

class FeedCache {
  private let url: URL
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private var urlString: String {
    return url.absoluteString
  }
  private var path: String? {
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsURL = NSURL(fileURLWithPath: paths.first!, isDirectory: true)
    let fullURL = documentsURL.appendingPathComponent("URL\(urlString.hashValue).xml")
    return fullURL?.path
  }

  func cache(document: FrozenElement) {
    guard let path = path else {
      return
    }
    guard let contents = try? encoder.encode(document as? XMLElement) else {
      return
    }
    FileManager.default.createFile(atPath: path, contents: contents, attributes: nil)
  }
  
  func fetch() -> FrozenElement? {
    guard let path = path else {
      return nil
    }
    guard let contents = FileManager.default.contents(atPath: path) else {
      return nil
    }
    return try? decoder.decode(XMLElement.self, from: contents)
  }

  init(url: URL) {
    self.url = url
  }
}
