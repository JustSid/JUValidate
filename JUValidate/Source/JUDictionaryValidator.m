//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUDictionaryValidator.h"
#import "JUBlockValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);

@implementation JUDictionaryValidator
{

}

- (JUValidator * (^)(id<NSCopying>))objectForKey
{
	return ^JUValidator *(id<NSCopying> key) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSDictionary class] withBlock:^id (NSDictionary *object, NSError **error) {

			id value = [object objectForKey:key];

			if(!value)
				*error = JUMakeError(JUValidatorErrorInvalidKey, [NSString stringWithFormat:@"No object for key %@", key]);

			return value;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUDictionaryValidator * (^)(NSUInteger))countIs
{
	return ^JUDictionaryValidator * (NSUInteger count) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:[NSDictionary class] withBlock:^id (NSDictionary *object, NSError **error) {

			if([object count] != count)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected %llu objects in dictionary, but found %llu", (unsigned long long)count, (unsigned long long)[object count]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

@end
