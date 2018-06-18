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
  enum Get {
    case error
    case success([Mark])
  }
  static var `default` = Persitence.init()

  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let database = CKContainer.default().privateCloudDatabase
  var recordIDByMark = [Mark: CKRecordID]()
  func delete(mark: Mark, with completion: @escaping (_ success: Bool) -> Void) {
    guard let recordID = recordIDByMark[mark] else {
      return
    }
    database.delete(withRecordID: recordID) { (_, error) in
      if error == nil {
        completion(true)
      } else {
        completion(false)
      }
    }
  }

  func get(completion: @escaping (Get) -> Void) {
    let query = CKQuery(
      recordType: MarkRecordType.feed.asType(),
      predicate: NSPredicate(value: true)
    )

    database.perform(query, inZoneWith: nil) { (records, error) in
      let marks = records?.compactMap({ (record) -> Mark? in
        guard let data = record.object(forKey: "payload") as? Data else {
          return nil
        }
        guard let mark = try? self.decoder.decode(Mark.self, from: data) else {
          return nil
        }
        self.recordIDByMark[mark] = record.recordID
        return mark
      })

      DispatchQueue.main.async {
        if let marks = marks {
          completion(.success(marks))
        } else {
          completion(.error)
        }
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

struct Mark: Codable, Hashable {
  let name: String
  let url: URL
}
