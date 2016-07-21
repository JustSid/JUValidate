//
// Created by Sidney Just on 19/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUNumberValidator.h"
#import "JUBlockValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);

@implementation JUNumberValidator
{

}

- (JUNumberValidator * (^)())isInteger
{
	static const char *types[] = {
		@encode(char),
		@encode(short),
		@encode(int),
		@encode(long),
		@encode(long long),
		@encode(unsigned char),
		@encode(unsigned short),
		@encode(unsigned int),
		@encode(unsigned long),
		@encode(unsigned long long)
	};

	return ^JUNumberValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *number, NSError **error) {

			const char *realType = [number objCType];
			const size_t comparator = sizeof(types) / sizeof(const char *);

			BOOL found = NO;

			for(size_t i = 0; i < comparator; i ++)
			{
				if(strcmp(realType, types[i]) == 0)
				{
					found = YES;
					break;
				}
			}

			if(!found)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected integer type"]);
				return nil;
			}

			return number;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUNumberValidator * (^)())isFloatingPoint
{
	static const char *types[] = {
		@encode(float),
		@encode(double)
	};

	return ^JUNumberValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *number, NSError **error) {

			const char *realType = [number objCType];
			const size_t comparator = sizeof(types) / sizeof(const char *);

			BOOL found = NO;

			for(size_t i = 0; i < comparator; i ++)
			{
				if(strcmp(realType, types[i]) == 0)
				{
					found = YES;
					break;
				}
			}

			if(!found)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected floating point type"]);
				return nil;
			}

			return number;

		}];

		return JUAddProxyValidator(validator);
	};
}


- (JUNumberValidator * (^)())__isType:(const char *)type name:(NSString *)name
{
	NSString *stringType = [NSString stringWithUTF8String:type];

	return ^JUNumberValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *number, NSError **error) {

			NSString *realType = [NSString stringWithUTF8String:[number objCType]];

			if(![realType isEqualToString:stringType])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected %@ type (got %@, want %@)", name, realType, stringType]);
				return nil;
			}

			return number;

		}];

		return JUAddProxyValidator(validator);
	};
}

#define isType(type) [self __isType:@encode(type) name:@#type]

- (JUNumberValidator * (^)())isFloat
{
	return isType(float);
}
- (JUNumberValidator * (^)())isDouble
{
	return isType(double);
}

- (JUNumberValidator * (^)())isBoolean
{
	return isType(BOOL);
}


- (JUNumberValidator * (^)())isTrue
{
	return ^JUNumberValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *number, NSError **error) {

			if(strcmp([number objCType], @encode(BOOL)) != 0 || ![number boolValue])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected True"]);
				return nil;
			}

			return number;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUNumberValidator * (^)())isFalse
{
	return ^JUNumberValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *number, NSError **error) {

			if(strcmp([number objCType], @encode(BOOL)) != 0 || [number boolValue])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected False"]);
				return nil;
			}

			return number;

		}];

		return JUAddProxyValidator(validator);
	};
}


- (JUNumberValidator * (^)())isChar
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(INT8_MIN), @(INT8_MAX));
	};
}
- (JUNumberValidator * (^)())isShort
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(INT16_MIN), @(INT16_MAX));
	};
}
- (JUNumberValidator * (^)())isInt
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(INT32_MIN), @(INT32_MAX));
	};
}
- (JUNumberValidator * (^)())isLong
{
	if(sizeof(long) == 4)
	{
		return ^JUNumberValidator *() {
			return self.isInteger().isInRange(@(INT32_MIN), @(INT32_MAX));
		};
	}
	else if(sizeof(long) == 8)
	{
		return ^JUNumberValidator *() {
			return self.isInteger().isInRange(@(INT64_MIN), @(INT64_MAX));
		};
	}
	else
	{
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"sizeof(long) != 4 or 8" userInfo:nil];
	}
}
- (JUNumberValidator * (^)())isLongLong
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(INT64_MIN), @(INT64_MAX));
	};
}


- (JUNumberValidator * (^)())isUnsignedChar
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(0), @(UINT8_MAX));
	};
}
- (JUNumberValidator * (^)())isUnsignedShort
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(0), @(UINT16_MAX));
	};
}
- (JUNumberValidator * (^)())isUnsignedInt
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(0), @(UINT32_MAX));
	};
}
- (JUNumberValidator * (^)())isUnsignedLong
{
	if(sizeof(unsigned long) == 4)
	{
		return ^JUNumberValidator *() {
			return self.isInteger().isInRange(@(0), @(UINT32_MAX));
		};
	}
	else if(sizeof(long) == 8)
	{
		return ^JUNumberValidator *() {
			return self.isInteger().isInRange(@(0), @(UINT64_MAX));
		};
	}
	else
	{
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"sizeof(unsigned long) != 4 or 8" userInfo:nil];
	}
}
- (JUNumberValidator * (^)())isUnsignedLongLong
{
	return ^JUNumberValidator *() {
		return self.isInteger().isInRange(@(0), @(UINT64_MAX));
	};
}


- (JUNumberValidator * (^)(NSNumber *))isLessThan
{
	return ^JUNumberValidator * (NSNumber *comparator) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *object, NSError **error) {

			NSComparisonResult result = [object compare:comparator];

			if(result == NSOrderedDescending || result == NSOrderedSame)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected < %@, but actual values was %@", comparator, object]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUNumberValidator * (^)(NSNumber *))isMoreThan
{
	return ^JUNumberValidator * (NSNumber *comparator) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *object, NSError **error) {

			NSComparisonResult result = [object compare:comparator];

			if(result == NSOrderedAscending || result == NSOrderedSame)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected > %@, but actual values was %@", comparator, object]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}


- (JUNumberValidator * (^)(NSNumber *))isLessOrEqualTo
{
	return ^JUNumberValidator * (NSNumber *comparator) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id(NSNumber *object, NSError **error) {

			NSComparisonResult result = [object compare:comparator];

			if(result == NSOrderedDescending)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected <= %@, but actual values was %@", comparator, object]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUNumberValidator * (^)(NSNumber *))isMoreOrEqualTo
{
	return ^JUNumberValidator * (NSNumber *comparator) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSNumber class] withBlock:^id (NSNumber *object, NSError **error) {

			NSComparisonResult result = [object compare:comparator];

			if(result == NSOrderedAscending)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected >= %@, but actual values was %@", comparator, object]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUNumberValidator * (^)(NSNumber *min, NSNumber *max))isInRange
{
	return ^JUNumberValidator * (NSNumber *min, NSNumber *max) {
		return self.isMoreOrEqualTo(min).isLessOrEqualTo(max);
	};
}

@end