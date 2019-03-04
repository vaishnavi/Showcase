//
//  Manager.swift
//  Showcase
//
//  Created by Vaishnavi on 26/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation

class Manager {
    
    private init() {}
    
    static let shared = Manager()

    func tableList(completion: @escaping ([Items]?) -> Void) {
        
        let firstItem = Items(title: "Item 1", subtitle: "Subtitle 1", tags: ["Tag1A", "Tag2A", "Tag3A"])
        let secondItem = Items(title: "Item 2", subtitle: "Subtitle 2", tags: ["Tag1B", "Tag2B", "Tag3B"])
        let thirdItem = Items(title: "Item 3", subtitle: "Subtitle 3", tags: ["Tag1C", "Tag2C", "Tag3C"])
        
        let itemList = [firstItem, secondItem, thirdItem]
        completion(itemList)
    }
    
}
