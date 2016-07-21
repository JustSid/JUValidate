//
// Created by Sidney Just on 18/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUStringValidator.h"
#import "JUBlockValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);

@implementation JUStringValidator
{

}

- (JUStringValidator * (^)(NSUInteger))lengthIs
{
	return ^JUStringValidator * (NSUInteger length) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			if([object length] != length)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected %llu length, but found length of %llu", (unsigned long long)length, (unsigned long long)[object length]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUStringValidator * (^)(NSUInteger))lengthIsLessThan
{
	return ^JUStringValidator * (NSUInteger length) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			if([object length] >= length)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected < %llu length, but found length of %llu", (unsigned long long)length, (unsigned long long)[object length]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUStringValidator * (^)(NSUInteger))lengthIsMoreThan
{
	return ^JUStringValidator * (NSUInteger length) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			if([object length] <= length)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected > %llu length, but found length of %llu", (unsigned long long)length, (unsigned long long)[object length]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}


- (JUStringValidator * (^)(NSUInteger))lengthIsLessOrEqualTo
{
	return ^JUStringValidator * (NSUInteger length) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id(NSString *object, NSError **error) {

			if([object length] > length)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected <= %llu length, but found length of %llu", (unsigned long long)length, (unsigned long long)[object length]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUStringValidator * (^)(NSUInteger))lengthIsMoreOrEqualTo
{
	return ^JUStringValidator * (NSUInteger length) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			if([object length] < length)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected >= %llu length, but found length of %llu", (unsigned long long)length, (unsigned long long)[object length]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUStringValidator * (^)(NSUInteger min, NSUInteger max))lengthIsInRange
{
	return ^JUStringValidator * (NSUInteger min, NSUInteger max) {
		return self.lengthIsMoreOrEqualTo(min).lengthIsLessOrEqualTo(max);
	};
}


- (JUStringValidator * (^)(NSString *))matches
{
	return ^JUStringValidator * (NSString *pattern) {
		return [self __matches](pattern, NO);
	};
}

- (JUStringValidator * (^)(NSString *))matchesCompletely
{
	return ^JUStringValidator * (NSString *pattern) {
		return [self __matches](pattern, YES);
	};
}

- (JUStringValidator * (^)(NSString *, BOOL))__matches
{
	return ^JUStringValidator * (NSString *pattern, BOOL completely) {

		NSError *error;
		NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];

		if(!regularExpression)
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Encountered error creating regular expression" userInfo:@{ NSUnderlyingErrorKey: error }];

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			NSTextCheckingResult *result = [regularExpression firstMatchInString:object options:0 range:NSMakeRange(0, [object length])];

			if(!result)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"'%@' doesn't match regular expressions %@", object, pattern]);
				return nil;
			}

			if(completely && [result range].length != [object length])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"'%@' doesn't completely match regular expressions %@", object, pattern]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUStringValidator * (^)())isUUID
{
	return ^JUStringValidator *() {
		return self.matchesCompletely(@"[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}");
	};
}
- (JUStringValidator * (^)())isInteger
{
	return ^JUStringValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			NSScanner *scan = [NSScanner scannerWithString:object];
			int temp;

			if(![scan scanInt:&temp] || ![scan isAtEnd])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, @"Expected integer");
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUStringValidator * (^)())isFloat
{
	return ^JUStringValidator * () {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSString class] withBlock:^id (NSString *object, NSError **error) {

			NSScanner *scan = [NSScanner scannerWithString:object];
			float temp;

			if(![scan scanFloat:&temp] || ![scan isAtEnd])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, @"Expected float");
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

@end