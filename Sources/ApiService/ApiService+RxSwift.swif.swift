//
//  ApiType+RxSwift.swif.swift
//  BeeJSONDemo
//
//  Created by snow on 2023/4/26.
//

import RxSwift

extension ApiType {
    
    func rxRequest(_ parameters: Any? = nil) -> Single<ApiResponse> {
        return ApiService.shared.rx.request(apiTarget, parameters: parameters ?? self.params)
    }
    
}

extension ApiService: ReactiveCompatible { }

public extension Reactive where Base: ApiService {
    
    func request(_ target: ApiTarget, parameters: Any?) -> Single<ApiResponse> {
        let `self` = base
        return Single<ApiResponse>.create { observer in
            let cancellable = self.request(target: target, parameters: parameters) { result in
                switch result {
                case .success(let response):
                    observer(.success(response))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
            
            return Disposables.create {
                cancellable.cancelRequest()
            }
        }
    }
}

public extension PrimitiveSequence {
    
    func retry(interval: RxTimeInterval, count: Int? = nil) -> PrimitiveSequence<Trait, Element> {
        return self.retry(when: { errors -> Observable<Int64> in
            return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                if let count = count, index >= count {
                    return Observable.error(error)
                }
                return Observable<Int64>.timer(interval, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
            }
        })
    }
    
}

public extension PrimitiveSequenceType where Trait == SingleTrait {
    
    func HUD(text: String = "加载中...") -> PrimitiveSequence<Trait, Element> {
        return self.do(onSuccess: { _ in
            ApiService.shared.hideHUD()
        }, onError: { _ in
            ApiService.shared.hideHUD()
        }, onSubscribed: {
            ApiService.shared.showHUD(text: text)
        })
    }
    
    func toastError() -> PrimitiveSequence<Trait, Element>  {
        return self.do(afterError: { error in
            ApiService.shared.showError(error)
        })
    }
    
    func model<ModelType: Decodable>(type: ModelType.Type) -> Single<ModelType> where Element == ApiResponse {
        return self.map { try $0.decode() }
    }
    
}
