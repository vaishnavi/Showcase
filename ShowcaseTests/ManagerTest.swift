//
//  ManagerTest.swift
//  ShowcaseTests
//
//  Created by Vaishnavi on 4/3/19.
//  Copyright © 2019 Vaishnavi. All rights reserved.
//

@testable import Showcase
import XCTest

class ManagerTest: XCTestCase {
    
    var complete = false
    var manager = Manager()
    
    override func setUp() {
        super.setUp()
        complete = false
    }
    
    override func tearDown() {
        complete = false
        super.tearDown()
    }
    
    func testFetchDetails() {
        manager.getList { _ in
            let service = ServiceMock()
            service.getDetails { _,_  in
                self.complete = true
            }
        }
    }
    
}

private final class ServiceMock: Service {
    
    var data: Data!
    
    override func getDetails(completion: @escaping Result) {
        guard let _ = """
            [
                {
                    "id": 1,
                    "name": "Leanne Graham",
                    "username": "Bret",
                    "email": "Sincere@april.biz",
                }
            ]
            """.data(using: .utf8) else {
                completion( data , "Test error message")
                return
        }
        completion(data, "Success")
    }
}
