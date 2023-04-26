//
//  ModuleMethod.m
//  BeeJSON
//
//  Created by snow on 2023/4/7.
//

#import "ModuleMethod.h"
#import <objc/message.h>
#import <objc/runtime.h>

typedef BOOL (^ArgumentBlock)(NSUInteger, id);

@implementation ModuleMethod {
    SEL _selector;
    NSInvocation *_invocation;
    NSArray<ArgumentBlock> *_argumentBlocks;
}

- (instancetype)initWithSelector:(SEL)selector
                     moduleClass:(Class)moduleClass; {
    if (self = [super init]) {
        _moduleClass = moduleClass;
        _selector = selector;
    }
    [self processMethodSignature];
    return self;
}

- (void)processMethodSignature
{
    if (_argumentBlocks != nil) {
        return;
    }
    
    NSMethodSignature *methodSignature = [_moduleClass instanceMethodSignatureForSelector:_selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    invocation.selector = _selector;
    _invocation = invocation;
    
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    NSMutableArray<ArgumentBlock> *argumentBlocks = [[NSMutableArray alloc] initWithCapacity:numberOfArguments - 2];
    
#define __PRIMITIVE_CASE(_type, getter, _nullable)                                      \
{                                                                                       \
    isNullableType = _nullable;                                                           \
    [argumentBlocks addObject:^(NSUInteger index, id any) { \
        _type value = [any getter];                        \
        [invocation setArgument:&value atIndex:(index) + 2];                              \
        return YES;                                                                       \
    }];                                                                                   \
    break;                                                                                \
}
    
#define PRIMITIVE_CASE(_type, getter) __PRIMITIVE_CASE(_type, getter, NO)
#define NULLABLE_PRIMITIVE_CASE(_type, getter) __PRIMITIVE_CASE(_type, getter, YES)
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) {
        const char *objcType = [methodSignature getArgumentTypeAtIndex:i];
        BOOL isNullableType = NO;
        switch (objcType[0]) {
            case _C_CHR:
                PRIMITIVE_CASE(char, charValue)
            case _C_UCHR:
                PRIMITIVE_CASE(unsigned char, unsignedCharValue)
            case _C_SHT:
                PRIMITIVE_CASE(short, shortValue)
            case _C_USHT:
                PRIMITIVE_CASE(unsigned short, unsignedShortValue)
            case _C_INT:
                PRIMITIVE_CASE(int, intValue)
            case _C_UINT:
                PRIMITIVE_CASE(unsigned int, unsignedIntValue)
            case _C_LNG:
                PRIMITIVE_CASE(long, longValue)
            case _C_ULNG:
                PRIMITIVE_CASE(unsigned long, unsignedLongValue)
            case _C_LNG_LNG:
                PRIMITIVE_CASE(long long, longLongValue)
            case _C_ULNG_LNG:
                PRIMITIVE_CASE(unsigned long long, unsignedLongLongValue)
            case _C_FLT:
                PRIMITIVE_CASE(float, floatValue)
            case _C_DBL:
                PRIMITIVE_CASE(double, doubleValue)
            case _C_BOOL:
                PRIMITIVE_CASE(BOOL, boolValue)
            case _C_SEL:
            case _C_CHARPTR:
            case _C_PTR:
            case _C_ID: {
                [argumentBlocks addObject:^(NSUInteger index, id any) {
                    id value = [any isMemberOfClass:NSNull.class] ? nil : any;
                    [invocation setArgument:&value atIndex:index + 2];
                    return YES;
                }];
                break;
            }
        }
    }
    _argumentBlocks = argumentBlocks;
}

- (id)invoke:(id)target arguments:(NSArray *)arguments {
    [self processMethodSignature];
    if(arguments.count < _argumentBlocks.count) {
        @throw [NSExpression expressionWithFormat:@"参数数量错误"];
    }

    for (NSUInteger index = 0; index < MIN(_argumentBlocks.count, arguments.count); index++) {
        id argument = arguments[index];
        ArgumentBlock block = _argumentBlocks[index];
        if(!block(index, argument)) {
            
        }
    }
    [_invocation invokeWithTarget:target];
    
    id returnValue = nil;
    NSMethodSignature *methodSignature = [_moduleClass instanceMethodSignatureForSelector:_selector];
    if(methodSignature.methodReturnLength > 0) {
        [_invocation getReturnValue:&returnValue];
    }
    return [returnValue copy];
}

@end
