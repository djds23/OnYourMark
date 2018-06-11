//
//  Mark.swift
//  OnYourMark
//
//  Created by Dean Silfen on 6/10/18.
//  Copyright © 2018 Dean Silfen. All rights reserved.
//

import UIKit
import CloudKit

class Persitence {
  static var `default` = Persitence.init()

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let database = CKContainer.default().privateCloudDatabase
  func get(completion: @escaping ([Mark]) -> Void) {
    let query = CKQuery(recordType: MarkRecordType.feed.asType(), predicate: NSPredicate(value: true))
    database.perform(query, inZoneWith: nil) { (records, error) in
      let marks = records?.compactMap({ (record) -> Mark? in
        guard let data = record.object(forKey: "payload") as? Data else {
          return nil
        }
        return try? self.decoder.decode(Mark.self, from: data)
      })
      DispatchQueue.main.async {
        completion(marks ?? [])
      }
    }
  }

  func set(mark: Mark, with completion: @escaping (_ success: Bool) -> Void) {
    let record = CKRecord(recordType: MarkRecordType.feed.asType())
    guard let data = try? encoder.encode(mark) as NSData else {
      completion(false)
      return
    }

    record.setObject(data, forKey: "payload")
    database.save(record) { (record, error) in
      DispatchQueue.main.async {
        completion(true)
      }
    }
  }
}

struct Mark: Codable {
  let name: String
  let url: URL
}
