//
//  Items.swift
//  Todoey
//
//  Created by Fadil Kurniawan on 15/06/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Items  : Codable {
    var title : String = ""
    var done : Bool = false
    
    init(title: String = "", done: Bool = false) {
        self.title = title
        self.done = done
    }
}


class Item  : Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
