//
//  Service.swift
//  Showcase
//
//  Created by Vaishnavi on 28/2/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

import Foundation

typealias Result = (Data, String) -> Void

class Service {
    
    private enum Constants {
        static let url = "https://jsonplaceholder.typicode.com/users"
    }

    private var serviceURL: URL? {
        let endpointURL = Constants.url
        return URL(string: endpointURL)
    }
    
    func getDetails(completion: @escaping Result) {
        if let url = serviceURL {
            let network = Network()
            network.genericDataTask(url: url) { (data,String)  in
                completion(data, String)
            }
        }
    }
}
