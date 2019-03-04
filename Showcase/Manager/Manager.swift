//
//  Manager.swift
//  Showcase
//
//  Created by Vaishnavi on 26/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation

class Manager {
    
    init() {}
    
    static let shared = Manager()
    
    func getList(completion: @escaping ([Names]?) -> Void){
        let service = Service()
        service.getDetails { (data, String) in
            do {
                let names = try JSONDecoder().decode([Names].self, from: data)
                completion(names)
            } catch let error {
                debugPrint("Data conversion error: \(error)")
                completion(nil)
            }
        }
    }
    
}
