//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JUDictionaryValidator;
@class JUArrayValidator;
@class JUStringValidator;
@class JUNumberValidator;

extern NSString *const JUValidatorErrorDomain;
extern NSString *const JUDetailedErrorsKey;

typedef NS_ENUM(NSInteger, JUValidatorError) {
	JUValidatorErrorValidationFailed,
	JUValidatorErrorInvalidClass,
	JUValidatorErrorInvalidKey,
	JUValidatorErrorOutOfBounds,
	JUValidateErrorInvalidLogic
};

@interface JUValidator : NSObject
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSArray<JUValidator *> *nextValidators;

- (JUDictionaryValidator *)dictionary;
- (JUArrayValidator *)array;
- (JUStringValidator *)string;
- (JUNumberValidator *)number;
- (JUValidator *)object;

- (JUValidator * (^)(NSString *))valueForKey;

- (JUValidator * (^)(Class))isClass;
- (JUValidator * (^)(id))isEqual;
- (JUValidator * (^)(id))isNotEqual;
- (JUValidator * (^)(id))isIdentical;
- (JUValidator * (^)(id))isNotIdentical;
- (JUValidator * (^)())isNull;
- (JUValidator * (^)())isNotNull;

- (JUDictionaryValidator * (^)())isDictionary;
- (JUArrayValidator * (^)())isArray;
- (JUStringValidator * (^)())isString;
- (JUNumberValidator * (^)())isNumber;

- (instancetype)and;

- (instancetype)ifOptionally;
- (JUValidator * (^)(void (^)(JUValidator *)))then;

- (JUValidator * (^)(BOOL (^)(id)))passesTest;
- (JUValidator * (^)(void (^)(JUValidator *)))validate;

- (JUValidator * (^)(NSString *))message;

- (void)addValidator:(JUValidator *)validator;

+ (instancetype)validatorWithName:(NSString *)name;
+ (instancetype)validatorWithName:(NSString *)name andSetupBlock:(void (^)(JUValidator *))setup;

+ (instancetype)validatorWrappingValidator:(JUValidator *)other;

@end

@interface JUValidator (Subclassing)
- (id)evaluateWithObject:(id)object error:(NSError **)error;
- (BOOL)validateObject:(id)object error:(NSError **)error;
@end

#define JUProxyValidator(validator) \
	({ id __proxy; __proxy = [[self class] validatorWrappingValidator:validator]; __proxy; })
#define JUAddProxyValidator(validator) \
	({ id __proxy = JUProxyValidator(validator); [self addValidator:__proxy]; __proxy; })
