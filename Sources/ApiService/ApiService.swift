//
//  Api.swift
//  BeeJSONDemo
//
//  Created by snow on 2023/3/15.
//

import Foundation
import BeeJSON

public enum ApiMethod: String {
    case GET
    case POST
}

public enum ApiContentType: String {
    case json = "application/json; charset=utf-8"
    case form = "application/x-www-form-urlencoded; charset=utf-8"
}

public protocol ApiCancellable {
    func cancelRequest()
}

public struct ApiResponse {
    public let code: Int
    public let message: String
    public let result: Any?
    public let data: Any?
    
    public init(code: Int, message: String, result: Any?, data: Any?) {
        self.code = code
        self.message = message
        self.result = result
        self.data = data
    }
    
    public func decode<ModeType: Decodable>() throws -> ModeType {
        if let value = data as? ModeType {
            return value
        }
        
        let data: Data = try {
            switch self.data {
            case let str as String:
                if let data = str.data(using: .utf8) {
                    return data
                }
            case let data as Data:
                return data
            default:
                if let any = self.data, JSONSerialization.isValidJSONObject(any) {
                    return try JSONSerialization.data(withJSONObject: any, options: [])
                }
            }
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "无效数据"])
        }()
        return try ApiService.shared.jsonDecoder.decode(ModeType.self, from: data)
    }
}

public protocol ApiProcessor {
    func requestURL(target: ApiTarget) -> URL
    func request(
        target: ApiTarget,
        parameters: Any?,
        completionHandler: @escaping (Result<ApiResponse, Error>) -> Void
    ) -> ApiCancellable
}

public protocol ApiTarget {
    static var processor: ApiProcessor { get }
    var path: String { get }
    var method: ApiMethod { get }
    var contentType: ApiContentType { get }
    var headers: [String: String] { get set }
}

extension ApiTarget {
    public var url: URL {
        return Self.processor.requestURL(target: self)
    }
}

public protocol ApiType {
    var apiTarget: ApiTarget { get }
    associatedtype ParamType
    var params: ParamType { get }
}

// MARK: - ApiServiceDelegage

public protocol ApiServiceDelegage: AnyObject {
    func showHUD(text: String)
    func hideHUD()
    func showError(_ error: Error)
}

// MARK: - ApiService

public class ApiService {
    
    public static let shared = ApiService()
    
    // MARK: - Internal
    
    private func ensureRunInMain(execute work: @escaping @convention(block) () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    func showHUD(text: String) {
        ensureRunInMain {
            self.delegate?.showHUD(text: text)
        }
    }
    
    func hideHUD() {
        ensureRunInMain {
            self.delegate?.hideHUD()
        }
    }
    
    func showError(_ error: Error) {
        ensureRunInMain {
            self.delegate?.showError(error)
        }
    }
    
    // MARK: - Public
    
    public weak var delegate: ApiServiceDelegage?
    
    public var jsonDecoder = BeeJSONDecoder()
    
    @discardableResult
    public func request(
        target: ApiTarget,
        parameters: Any?,
        completionHandler: @escaping (Result<ApiResponse, Error>) -> Void
    ) -> ApiCancellable
    {
        let processor = type(of: target).processor
        return processor.request(target: target,
                                 parameters: parameters,
                                 completionHandler: completionHandler)
    }
    
    public func toJSONObject(_ parameters: Any?) throws -> Any? {
        if let parameters = parameters {
            if JSONSerialization.isValidJSONObject(parameters) {
                return parameters
            }
            if parameters is Encodable {
                let data = try JSONEncoder().encode(JSONAny(parameters))
                return try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            }
            assert(parameters is Void, "参数错误：\(parameters)")
        }
        return nil
    }
    
    public func toData(_ parameters: Any?) throws -> Data? {
        if let parameters = parameters {
            if JSONSerialization.isValidJSONObject(parameters) {
                return try JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
            }
            if parameters is Encodable {
                return try JSONEncoder().encode(JSONAny(parameters))
            }
            assert(parameters is Void, "参数错误：\(parameters)")
        }
        return nil
    }
}


