//
// Created by Sidney Just on 19/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUValidator.h"


@interface JUNumberValidator : JUValidator

- (JUNumberValidator * (^)(NSNumber *))isLessThan;
- (JUNumberValidator * (^)(NSNumber *))isMoreThan;

- (JUNumberValidator * (^)(NSNumber *))isLessOrEqualTo;
- (JUNumberValidator * (^)(NSNumber *))isMoreOrEqualTo;

- (JUNumberValidator * (^)(NSNumber *min, NSNumber *max))isInRange;

- (JUNumberValidator * (^)())isInteger;
- (JUNumberValidator * (^)())isFloatingPoint;

- (JUNumberValidator * (^)())isFloat;
- (JUNumberValidator * (^)())isDouble;

// These don't check for the objCType, but rather if the value can be converted to the type without loss
- (JUNumberValidator * (^)())isBoolean;
- (JUNumberValidator * (^)())isTrue;
- (JUNumberValidator * (^)())isFalse;

- (JUNumberValidator * (^)())isChar;
- (JUNumberValidator * (^)())isShort;
- (JUNumberValidator * (^)())isInt;
- (JUNumberValidator * (^)())isLong;
- (JUNumberValidator * (^)())isLongLong;

- (JUNumberValidator * (^)())isUnsignedChar;
- (JUNumberValidator * (^)())isUnsignedShort;
- (JUNumberValidator * (^)())isUnsignedInt;
- (JUNumberValidator * (^)())isUnsignedLong;
- (JUNumberValidator * (^)())isUnsignedLongLong;

@end