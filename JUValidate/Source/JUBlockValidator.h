//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"


@interface JUBlockValidator : JUValidator
@property (nonatomic, strong) BOOL (^evaluateObject)(id, NSError **);

+ (JUBlockValidator *)validatorForClass:(Class)class withBlock:(id (^)(id, NSError **))block;

@end