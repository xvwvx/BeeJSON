//
//  BeeJSONTests.swift
//  BeeJSONDemoTests
//  
//  Created  by 张绍平 on 2022/3/21
//  
//  
	

import XCTest
import BeeJSON

class BeeJSONTests: XCTestCase {
    
    func isEqual<T: Equatable>(any: Any?, value: T) -> Bool {
        if let v = any as? T
        {
            return v == value
        }
        return false
    }
    
    func testDefaultValues() {
        
        struct Model: Codable, BeeJSON {
            
            var value0 = 0
            var value1 = true
            var value2 = "test"
            
            static func defaultValues() -> [String : Any] {
                return [
                    "value0": 123456789,
                    "value1": false,
                    "value2": "defaultValue2",
                ]
            }
        }
        
        let data = """
        {}
        """.data(using: .utf8)!
        let model = try? BeeJSONDecoder().decode(Model.self, from: data)
        XCTAssert(model != nil)
        
        let values = Model.defaultValues()
        XCTAssert(isEqual(any: values["value0"], value: model?.value0))
        XCTAssert(isEqual(any: values["value1"], value: model?.value1))
        XCTAssert(isEqual(any: values["value2"], value: model?.value2))
        
    }
    
    func testNested() {
        struct Model: Codable {
            struct Value<T>: Codable where T: Codable {
                var value0: T
                var value1: T
                var value2: T
                var value3: T
            }
            
            var value: Value<String>
            var array: [Value<String>]
            var other: [String]
        }
        
        let jsonStr = """
        {
            "value": {
                "value0": "99",
                "value1": true,
                "value2": 18446744073709551615,
                "value3": 100.99
            },
            "array": [
                {
                    "value0": "99",
                    "value1": true,
                    "value2": 18446744073709551615,
                    "value3": 100.99
                }
            ],
            "other": [
                "测试",
                "测试",
                "测试"
            ]
        }
        """
        
        let jsonData = jsonStr.data(using: .utf8)!
        do {
            let model = try BeeJSONDecoder().decode(Model.self, from: jsonData)
            let first = model.other.first
            XCTAssert(first != nil)
            XCTAssertEqual(model.other.filter({ $0 == first! }).count, 3)
        } catch {
            print(error)
            XCTAssertThrowsError(error)
        }
    }
    
    func testWrongType() {
        struct Model: Codable {
            struct Value<T>: Codable where T: Codable {
                var value0: T
                var value1: T
                var value2: T
                var value3: T
            }
            
            var String: Value<String>
            var Bool: Value<Bool>
            var Int8: Value<Int8>
            var Int16: Value<Int16>
            var Int32: Value<Int32>
            var Int64: Value<Int64>
            var UInt8: Value<UInt8>
            var UInt16: Value<UInt16>
            var UInt32: Value<UInt32>
            var UInt64: Value<UInt64>
        }

        let types: [Any.Type] = [
            String.self, Bool.self,
            Int8.self, Int16.self, Int32.self, Int64.self,
            UInt8.self, UInt16.self, UInt32.self, UInt64.self,
        ]
        
        let text = types.map { type in
            let value = type == Bool.self ? true.description : 99.description
            return """
            "\(type)": {
                "value0": "\(value)",
                "value1": true,
                "value2": \(UInt64.max),
                "value3": 100.99,
            }
            """
        }.joined(separator: ",")
        
        let jsonStr = "{\(text)}"
        
        let jsonData = jsonStr.data(using: .utf8)!
        do {
            let model = try BeeJSONDecoder().decode(Model.self, from: jsonData)
            XCTAssertEqual(model.UInt64.value2, UInt64.max)
        } catch {
            XCTAssertThrowsError(error)
        }
        
    }
    
    func testIgnore() {
        struct Model: Encodable {
            @JSONIgnore<NSDecimalNumber>(NSDecimalNumber(string: "0.00001")) var value: NSDecimalNumber
            @JSONIgnore<Int>(1234567890) var value1: Int
        }
        var origin = Model()
        origin.value = NSDecimalNumber(string: "0.00001")
        
        let data = try? BeeJSONEncoder().encode(origin)
        XCTAssert(data != nil)
        
        let str = String(data: data!, encoding: .utf8) ?? ""
        
        XCTAssert(!str.contains(origin.value.stringValue))
        XCTAssert(!str.contains(origin.value1.description))
    }
    
    func testAny() {
        struct Model: Codable {
            @JSONAny<[Any]>([]) var array: [Any]
            @JSONAny<[String: Any]>([:]) var dict: [String: Any]
        }
        
        var origin = Model()
        origin.array = [123456789, true, "test", 10.5, UInt64.max]
        origin.dict = [
            "value0": 0x123456789,
            "value1": true,
            "value2": "test",
            "value3": UInt64.max,
        ]
        
        
        let data = try? BeeJSONEncoder().encode(origin)
        XCTAssert(data != nil)
        
        let model = try? BeeJSONDecoder().decode(Model.self, from: data!)
        XCTAssert(model?.array != nil)
        XCTAssert(model?.dict != nil)
        
        let result = try? JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String: Any]
        XCTAssert(result != nil)
        
        let array = result?["array"] as? [Any]
        XCTAssert(array != nil)
        XCTAssert(isEqual(any: array?[0], value: 123456789))
        XCTAssert(isEqual(any: array?[1], value: true))
        XCTAssert(isEqual(any: array?[2], value: "test"))
        XCTAssert(isEqual(any: array?[3], value: Float64(10.5)))
        XCTAssert(isEqual(any: array?[4], value: UInt64.max))
        
        let dict = result?["dict"] as? [String: Any]
        XCTAssert(dict != nil)
        XCTAssert(isEqual(any: dict?["value0"], value: 0x123456789))
        XCTAssert(isEqual(any: dict?["value1"], value: true))
        XCTAssert(isEqual(any: dict?["value2"], value: "test"))
        XCTAssert(isEqual(any: dict?["value3"], value: UInt64.max))
        
    }
    
    func testNSDecimalNumberWrapper() {
        struct Model: Codable {
            @JSONDecimalNumber var value: NSDecimalNumber
        }
        
        var origin = Model()
        origin.value = NSDecimalNumber(string: "0.00001")
        
        let data = try? BeeJSONEncoder().encode(origin)
        XCTAssert(data != nil)
        
        let str = String(data: data!, encoding: .utf8) ?? ""
        XCTAssert(str.contains(origin.value.stringValue))
        
        let model = try? BeeJSONDecoder().decode(Model.self, from: data!)
        XCTAssert(model?.value == origin.value)
    }
    
    func testTextWrapper() {
        struct Value: Codable {
            var value0 = 0
            var value1 = true
            var value2 = "test"
            @JSONDecimalNumber var value3: NSDecimalNumber
        }
        
        struct Model: Codable {
            @JSONText(Value()) var value: Value
        }
        
        var origin = Model()
        origin.value.value3 = NSDecimalNumber(string: "0.00001")
        
        let encoder = BeeJSONEncoder()
        if #available(iOS 11.0, *) {
            encoder.outputFormatting = [.sortedKeys]
        }
        let data = try? encoder.encode(origin)
        XCTAssert(data != nil)
        
        let str = String(data: data!, encoding: .utf8) ?? ""
        XCTAssert(str.contains(origin.value.value3.stringValue))
        
        let model = try? BeeJSONDecoder().decode(Model.self, from: data!)
        XCTAssertEqual(model?.value.value0, origin.value.value0)
        XCTAssertEqual(model?.value.value1, origin.value.value1)
        XCTAssertEqual(model?.value.value2, origin.value.value2)
        XCTAssertEqual(model?.value.value3, origin.value.value3)
    }
    
}
