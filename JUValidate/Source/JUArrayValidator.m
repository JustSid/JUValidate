//
// Created by Sidney Just on 18/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUArrayValidator.h"
#import "JUBlockValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);
extern NSError *JUMakeCompoundError(JUValidatorError code, NSString *reason, NSArray<NSError *> *errors);

@implementation JUArrayValidator
{

}

- (JUArrayValidator * (^)(void (^)(JUValidator *)))each
{
	JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {
		return object;
	}];

	__weak JUBlockValidator *blockValidator = validator;

	[validator setEvaluateObject:^BOOL (NSArray *array, NSError **error) {

		JUBlockValidator *strongValidator = blockValidator;
		if(!strongValidator)
			return NO;

		NSMutableArray *accumulatedErrors = [NSMutableArray array];

		for(id object in array)
		{
			for(JUValidator *validator in [strongValidator nextValidators])
			{
				NSError *tempError;
				BOOL result = [validator validateObject:object error:&tempError];

				if(!result)
				{
					if(!tempError)
						tempError = JUMakeError(JUValidatorErrorValidationFailed, @"Validator failed but didn't return an error");

					[accumulatedErrors addObject:tempError];
				}
			}
		}

		if([accumulatedErrors count] > 0)
		{
			if([accumulatedErrors count] == 1)
				*error = [accumulatedErrors objectAtIndex:0];
			else
				*error = JUMakeCompoundError(JUValidatorErrorValidationFailed, @"Validators failed", accumulatedErrors);

			return NO;
		}

		return YES;

	}];

	JUArrayValidator *proxy = JUProxyValidator(validator);
	[self addValidator:proxy];

	return ^JUArrayValidator * (void (^setup)(JUValidator *)) {
		setup(proxy);
		return proxy;
	};
}

- (JUValidator * (^)(NSUInteger))objectAtIndex
{
	return ^JUValidator * (NSUInteger index) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if([object count] <= index)
			{
				*error = JUMakeError(JUValidatorErrorOutOfBounds, [NSString stringWithFormat:@"Index %llu is out of bounds for array", (unsigned long long)index]);
				return nil;
			}

			id value = [object objectAtIndex:index];
			return value;

		}];

		[self addValidator:validator];
		return validator;
	};
}

- (JUArrayValidator * (^)(id))containsObject
{
	return ^JUArrayValidator * (id other) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if(![object containsObject:other])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Object %@ is not in array", other]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUArrayValidator * (^)(NSUInteger))countIs
{
	return ^JUArrayValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if([object count] != count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected %llu objects in array, but found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUArrayValidator * (^)(NSUInteger))countIsLessThan
{
	return ^JUArrayValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if([object count] >= count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected < %llu objects in array, but only found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUArrayValidator * (^)(NSUInteger))countIsMoreThan
{
	return ^JUArrayValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if([object count] <= count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected > %llu objects in array, but only found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);

	};
}


- (JUArrayValidator * (^)(NSUInteger))countIsLessOrEqualTo
{
	return ^JUArrayValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id(NSArray *object, NSError **error) {

			if([object count] > count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected <= %llu objects in array, but only found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUArrayValidator * (^)(NSUInteger))countIsMoreOrEqualTo
{
	return ^JUArrayValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSArray class] withBlock:^id (NSArray *object, NSError **error) {

			if([object count] < count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected >= %llu objects in array, but only found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUArrayValidator * (^)(NSUInteger min, NSUInteger max))countIsInRange
{
	return ^JUArrayValidator * (NSUInteger min, NSUInteger max) {
		return self.countIsMoreOrEqualTo(min).countIsLessOrEqualTo(max);
	};
}

@end