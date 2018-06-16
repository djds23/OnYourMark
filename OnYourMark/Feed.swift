//
//  Feed.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/11/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

class Feed: NSObject {
  init(url: URL) {
    XMLParser(contentsOf: <#T##URL#>)
  }
}

class FeedRequestController {
  func sendRequest() {
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    guard var URL = URL(string: "https://useyourloaf.com/blog/rss.xml") else {return}
    var request = URLRequest(url: URL)
    request.httpMethod = "GET"
    let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
      if (error == nil) {
      }
      else {
        // Failure
        print("URL Session Task Failed: %@", error!.localizedDescription);
      }
    })
    task.resume()
    session.finishTasksAndInvalidate()
  }
}



