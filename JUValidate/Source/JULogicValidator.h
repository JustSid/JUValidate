//
// Created by Sidney Just on 19/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"

typedef NS_ENUM(NSInteger, JULogicValidatorType) {
	JULogicValidatorTypeNop,
	JULogicValidatorTypeIf,
	JULogicValidatorTypeEndIf
};

@interface JULogicValidator : JUValidator
@property (nonatomic, assign, readonly) JULogicValidatorType type;

+ (instancetype)validatorWithType:(JULogicValidatorType)type;

@end
