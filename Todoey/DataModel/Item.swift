//
//  Item.swift
//  Todoey
//
//  Created by Vera Dias on 26/05/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable{
    let title: String
    var done: Bool
    
    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }
}
