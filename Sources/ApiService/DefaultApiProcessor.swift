//
//  DefaultApiProcessor.swift
//  BeeJSONDemo
//
//  Created by snow on 2023/4/26.
//

open class DefaultApiProcessor: ApiProcessor {
    
    public static let shared = DefaultApiProcessor()
    public init() {}
    
    open func requestURL(target: ApiTarget) -> URL {
        if let url = URL(string: target.path) {
            return url
        }
        fatalError("无效的url")
    }
    
    open func request(
        target: ApiTarget,
        parameters: Any?,
        completionHandler: @escaping (Result<ApiResponse, Error>) -> Void
    ) -> ApiCancellable
    {
        let url = target.url
        return request(url: url, requestModifier: { request in
            if target.method == .GET || target.contentType == .form {
                if let dict = try? ApiService.shared.toJSONObject(parameters) as? [String: Any],
                   dict.count > 0 {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                    components.queryItems = dict.reduce(into: components.queryItems ?? [], { result, args in
                        if !(args.value is NSNull) {
                            result?.append(URLQueryItem(name: "\(args.key)", value: "\(args.value)"))
                        }
                    })
                    if target.method == .POST {
                        request.httpBody = components.query?.data(using: .utf8)
                    } else {
                        request.url = components.url!
                    }
                }
            } else {
                request.httpBody = try? ApiService.shared.toData(parameters)
            }
            
            request.httpMethod = target.method.rawValue
            request.allHTTPHeaderFields = {
                var headers = target.headers
                if headers["Content-Type"] == nil {
                    headers["Content-Type"] = target.contentType.rawValue
                }
                return headers
            }()
        }, completionHandler: completionHandler)
    }
    
    open func request(
        url: URL,
        requestModifier: (_ request: inout URLRequest) -> Void,
        completionHandler: @escaping (Result<ApiResponse, Error>) -> Void
    ) -> ApiCancellable {
        var request = URLRequest(url: url)
        requestModifier(&request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                if let error = error {
                    throw error
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    return
                }
                
                if response.statusCode >= 200 && response.statusCode <= 201 {
                    let resp = ApiResponse(code: 0, message: "", result: data, data: data)
                    completionHandler(.success(resp))
                } else {
                    throw NSError(domain: url.path, code: response.statusCode)
                }
            } catch {
                completionHandler(.failure(error))
            }
        }
        
        task.resume()
        return task
    }
    
}

extension URLSessionTask: ApiCancellable {
    public func cancelRequest() {
        self.cancel()
    }
}

