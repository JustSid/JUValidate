//
// Created by Sidney Just on 18/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"


@interface JUArrayValidator : JUValidator

- (JUArrayValidator * (^)(void (^)(JUValidator *)))each;

- (JUValidator * (^)(NSUInteger))objectAtIndex;
- (JUArrayValidator * (^)(id))containsObject;

- (JUArrayValidator * (^)(NSUInteger count))countIs;
- (JUArrayValidator * (^)(NSUInteger))countIsLessThan;
- (JUArrayValidator * (^)(NSUInteger))countIsMoreThan;

- (JUArrayValidator * (^)(NSUInteger count))countIsLessOrEqualTo;
- (JUArrayValidator * (^)(NSUInteger count))countIsMoreOrEqualTo;

- (JUArrayValidator * (^)(NSUInteger min, NSUInteger max))countIsInRange;

@end