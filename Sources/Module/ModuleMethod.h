//
//  ModuleMethod.h
//  BeeJSON
//
//  Created by snow on 2023/4/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ModuleMethod : NSObject

@property (nonatomic, readonly) Class moduleClass;
@property (nonatomic, readonly) SEL selector;

- (instancetype)initWithSelector:(SEL)selector
                     moduleClass:(Class)moduleClass;

- (id)invoke:(id)target arguments:(NSArray *)arguments;

@end

NS_ASSUME_NONNULL_END
