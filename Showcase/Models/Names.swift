//
//  Items.swift
//  Showcase
//
//  Created by Vaishnavi on 26/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation

struct Names: Codable {
    
    let id: Int
    let name: String?
    let username: String?
    let email: String?
    //let address: [Address]
}

struct Address: Codable {
    let street: String?
    let suite: String?
    let city: String?
    let zipcode: Int?
    let location: [Location]
    
    private enum CodingKeys: String, CodingKey {
        case street = "street"
        case suite = "suite"
        case city = "city"
        case zipcode = "zipcode"
        case location = "geo"
    }
}

struct Location: Codable {
    let latitude: String
    let longitude: String
}

