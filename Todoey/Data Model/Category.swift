//
//  Category.swift
//  Todoey
//
//  Created by Fadil Kurniawan on 09/07/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let items = List<Item>()
}
