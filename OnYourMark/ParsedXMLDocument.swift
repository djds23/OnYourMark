//
//  ParsedXMLDocument.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/17/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit

enum XMLParseError: Error {
  case failedWhileParsingError
  case nilParserError
}

typealias ParsedXMLDocumentCompletion = () -> Void

protocol ParsedXMLDocumentDelegate: class {
  func parsedXMLDocument(didUpdate document: FrozenElement)
  func parsedXMLDocument(error: XMLParseError)
}

protocol FrozenElement: Codable {
  var children: [FrozenElement] { get }
  var name: String? { get }
  var body: String? { get }
  var attributes: [String: String] { get }
  func findChildBy(name: String) -> FrozenElement?
  func findChildrenBy(names: [String]) -> [FrozenElement]
}

class ParsedXMLDocument {
  let parser: XMLParser?
  weak var delegate: ParsedXMLDocumentDelegate?
  init(parser: XMLParser?) {
    self.parser = parser
  }
  
  func parse() {
    guard let theParser = parser else {
      self.delegate?.parsedXMLDocument(error: .nilParserError)
      return
    }
    let document = XMLElement()
    document.name = "root"
    document.parser = theParser
    theParser.delegate = document

    if !theParser.parse() {
      self.delegate?.parsedXMLDocument(
        error: .failedWhileParsingError
      )
    } else {
      self.delegate?.parsedXMLDocument(
        didUpdate: document
      )
    }
  }
}

class XMLElement: NSObject, FrozenElement {
  var children: [FrozenElement] = []
  var name: String?
  var body: String?
  var attributes: [String: String] = [:]
  var parent: XMLElement?
  var parser: XMLParser?
  
  func findChildBy(name: String) -> FrozenElement? {
    var foundElement: FrozenElement? = nil
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

  func findChildrenBy(names: [String]) -> [FrozenElement] {
    var foundElements = [FrozenElement]()
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
  
  override init() {}

  enum CodingKeys: String, CodingKey {
    case children
    case name
    case body
    case attributes
  }
  
  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decodeIfPresent(String.self, forKey: .name)
    body = try values.decodeIfPresent(String.self, forKey: .body)
    attributes = try values.decode([String: String].self, forKey: .attributes)
    children = try values.decode([XMLElement].self, forKey: .children)
  }
  
  func encode(to encoder: Encoder) throws {
    guard let concreteChildren = children as? [XMLElement] else {
      let context = EncodingError.Context(codingPath: [CodingKeys.children], debugDescription: "Class is not castable to concrete element.")
      throw EncodingError.invalidValue(children, context)
    }
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encodeIfPresent(body, forKey: .body)
    try container.encode(attributes, forKey: .attributes)
    try container.encode(concreteChildren, forKey: .children)
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
}

extension XMLElement {
  override var description: String {
    return "<Element-\(name): \(body) \(children)>"
  }
}
