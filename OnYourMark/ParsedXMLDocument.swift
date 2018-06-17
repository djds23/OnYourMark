//
//  ParsedXMLDocument.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/17/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit


typealias ParsedXMLDocumentCompletion = () -> Void

protocol ParsedXMLDocumentDelegate: class {
  func parsedXMLDocument(didUpdate document: XMLElement)
}

class ParsedXMLDocument {
  var document: XMLElement?
  let parser: XMLParser?
  
  weak var delegate: ParsedXMLDocumentDelegate?
  init(parser: XMLParser?) {
    self.parser = parser
  }
  
  func parse() {
    document = XMLElement()
    document?.name = "root"
    document?.parser = parser
    document?.completionBlock = { [weak self] in
      guard let doc = self?.document else { return }
      self?.delegate?.parsedXMLDocument(didUpdate: doc)
    }
    parser?.delegate = document
    parser?.parse()
  }
}

class XMLElement: NSObject {
  var children: [XMLElement] = []
  var name: String?
  var body: String?
  var attributes: [String: String] = [:]
  var parent: XMLElement?
  var parser: XMLParser?
  var completionBlock: ParsedXMLDocumentCompletion?
  
  func findChildBy(name: String) -> XMLElement? {
    var foundElement: XMLElement? = nil
    for element in children {
      if element.name == name {
        foundElement = element
        break
      } else {
        foundElement = element.findChildBy(name: name)
      }
    }
    return foundElement
  }

  func findChildrenBy(names: [String]) -> [XMLElement] {
    var foundElements = [XMLElement]()
    for element in children {
      if let name = element.name {
        if names.index(of: name) != nil {
          foundElements.append(element)
        } else {
          foundElements += element.findChildrenBy(names: names)
        }
      }
    }
    return foundElements
  }
}

extension XMLElement: XMLParserDelegate {
  func parserDidStartDocument(_ parser: XMLParser) {
  }
  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    body = string
  }
  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    let child = XMLElement()
    child.name = elementName
    child.attributes = attributeDict
    child.parent = self
    self.children.append(child)
    child.parser = parser
    parser.delegate = child
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    parser.delegate = self.parent
  }
  
  func parserDidEndDocument(_ parser: XMLParser) {
    completionBlock?()
  }
}

extension XMLElement {
  override var description: String {
    return "<Element-\(name): \(body) \(children)>"
  }
}
