// ('w') GitHub pushtest
//  Meal.swift
//  FoodTracker
//
//  Created by yumi kanebayashi on 2020/10/19.
//

// Mealオブジェクト キーを設定して保存場所も設定して、エンコードして保存(TableViewCell内) デコードしてinit生成

import UIKit
import os.log

class Meal: NSObject, NSSecureCoding {
    
    // MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // エンコードしたデータの保存場所を決める　Meal.ArchiveURL.path
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    // MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    // MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int) {
        
        // 空文字、負の数の場合　失敗
        // Initialization should fall if there is no name or if the rating is negative.
//        if name.isEmpty || rating < 0 {
//            return nil
//        }
        // The name must not be empty.
        // ! is 真偽値反転
        guard !name.isEmpty else {
            return nil
        }
        // The rating must not be between 0 and 5 inclusively
        guard rating >= 0 && rating <= 5 else {
            return nil
        }
        // Initialized stored properties
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    // オブジェクト生成
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    required convenience init?(coder aDecorder: NSCoder) {
        // name,photo,ratingのプロパティを呼び出す
        
        // The name is required. If we cannot decode a name string, the initializer should fall.
        guard let name = aDecorder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal Object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecorder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        
        let rating = aDecorder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)
    }
    
    // MARK: NSSecureCoding
    static var supportsSecureCoding: Bool = true
}
