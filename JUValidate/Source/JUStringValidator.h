//
// Created by Sidney Just on 18/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"


@interface JUStringValidator : JUValidator

- (JUStringValidator * (^)(NSUInteger length))lengthIs;
- (JUStringValidator * (^)(NSUInteger))lengthIsLessThan;
- (JUStringValidator * (^)(NSUInteger))lengthIsMoreThan;

- (JUStringValidator * (^)(NSUInteger length))lengthIsLessOrEqualTo;
- (JUStringValidator * (^)(NSUInteger length))lengthIsMoreOrEqualTo;

- (JUStringValidator * (^)(NSUInteger min, NSUInteger max))lengthIsInRange;

- (JUStringValidator * (^)(NSString *pattern))matches;
- (JUStringValidator * (^)(NSString *pattern))matchesCompletely;

- (JUStringValidator * (^)())isUUID;
- (JUStringValidator * (^)())isInteger;
- (JUStringValidator * (^)())isFloat;

@end