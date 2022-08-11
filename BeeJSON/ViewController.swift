//
//  ViewController.swift
//  BeeJSON
//
//  Created by snow on 2022/8/9.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        testModel()
        testModel1()
        
        do {
            defer {
                print("11111111111111")
            }
            print("222222222222222222222")
        }
        do {
            defer {
                print("33333333333")
            }
            print("4444444444444444")
        }
    }

    func testModel() {
        
    }
    
    func testModel1() {
        
        struct Model: BeeJSON {
            var value0 = 0
            var value1 = ""
//            var value2 = false
            var array0: [Int] = []
            
            mutating func mapping(mapper: inout CustomModelMapper) {
                mapper.specify(property: &value0, name: "value01")
//                mapper.exclude(property: &value1)
            }
        }
        
        let dict: [String: Any] = [
            "value0": 9999,
            "value1": "测试",
            "value2": true,
            "value01": 12345678,
            "array0": [1, 2, 3, "4", "true"],
        ]
        let model = Model.transform(from: dict)
        print(model)
        
        let beeJSON: BeeJSON? = model
        print(beeJSON?.plainValue())
    }
    
}

