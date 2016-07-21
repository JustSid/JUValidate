//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"

@interface JUDictionaryValidator : JUValidator

- (JUValidator * (^)(id<NSCopying>))objectForKey;

- (JUDictionaryValidator * (^)(NSUInteger count))countIs;

@end
