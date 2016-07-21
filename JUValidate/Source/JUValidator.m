//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUValidator.h"
#import "JUBlockValidator.h"
#import "JUDictionaryValidator.h"
#import "JUArrayValidator.h"
#import "JUStringValidator.h"
#import "JUNumberValidator.h"
#import "JULogicValidator.h"

static NSRecursiveLock *lookupLock;
static NSMutableDictionary *lookupTable;

NSString *const JUValidatorErrorDomain = @"JUValidatorErrorDomain";
NSString *const JUDetailedErrorsKey = @"JUDetailedErrorsKey";

NSError *JUMakeError(JUValidatorError code, NSString *reason)
{
	NSDictionary *info = reason ? @{ NSLocalizedDescriptionKey: reason } : nil;
	return [NSError errorWithDomain:JUValidatorErrorDomain code:code userInfo:info];
}

NSError *JUMakeCompoundError(JUValidatorError code, NSString *reason, NSArray<NSError *> *errors)
{
	NSMutableDictionary *info = [NSMutableDictionary dictionary];

	if(reason)
		[info setObject:reason forKey:NSLocalizedDescriptionKey];
	if([errors count] > 0)
		[info setObject:errors forKey:JUDetailedErrorsKey];

	return [NSError errorWithDomain:JUValidatorErrorDomain code:code userInfo:info];
}

@implementation JUValidator
{
	JUValidator *_wrappedValidator;
	NSMutableArray<JUValidator *> *_validators;
}

+ (void)load
{
	lookupLock = [[NSRecursiveLock alloc] init];
	lookupTable = [[NSMutableDictionary alloc] init];
}

- (void)addValidator:(JUValidator *)validator
{
	[[self validators] addObject:validator];
}

- (NSArray<JUValidator *> *)nextValidators
{
	NSMutableArray<JUValidator *> *validators = [[self validators] mutableCopy];
	NSUInteger count = [validators count];

	for(NSUInteger i = 0; i < count; i ++)
	{
		JUValidator *validator = [validators objectAtIndex:i];

		if(validator->_wrappedValidator)
		{
			JUValidator *real = validator->_wrappedValidator;
			while(real)
			{
				JUValidator *next = real->_wrappedValidator;
				if(!next)
					break;

				real = next;
			}

			[validators replaceObjectAtIndex:i withObject:real];
		}
	}

	return validators;
}

- (NSMutableArray<JUValidator *> *)validators
{
	if(_wrappedValidator)
		return [_wrappedValidator validators];

	return _validators;
}

#pragma mark -
#pragma mark Solver

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
	if(_wrappedValidator)
		return [_wrappedValidator evaluateWithObject:object error:error];

	return object;
}

- (BOOL)validateObject:(id)object error:(NSError **)error
{
	if(_wrappedValidator)
		return [_wrappedValidator validateObject:object error:error];

	object = [self evaluateWithObject:object error:error];

	if(!object)
		return NO;

	// Sub validators
	NSMutableArray<NSError *> *errors = [NSMutableArray array];

	for(JUValidator *validator in [self validators])
	{
		NSError *tempError = nil;
		if(([validator validateObject:object error:&tempError]))
			continue;

		if(!tempError)
			tempError = JUMakeError(JUValidatorErrorValidationFailed, @"Validator failed, but didn't return an error");

		[errors addObject:tempError];
	}

	if(error && [errors count])
	{
		if([errors count] == 1)
			*error = [errors objectAtIndex:0];
		else
			*error = JUMakeCompoundError(JUValidatorErrorValidationFailed, @"Validators failed", errors);
	}

	return ([errors count] == 0);
}


#pragma mark -
#pragma mark Helper

- (JUDictionaryValidator *)dictionary
{
	JUDictionaryValidator *validator = [[JUDictionaryValidator alloc] init];
	[self addValidator:validator];

	return validator;
}

- (JUArrayValidator *)array
{
	JUArrayValidator *validator = [[JUArrayValidator alloc] init];
	[self addValidator:validator];

	return validator;
}

- (JUStringValidator *)string
{
	JUStringValidator *validator = [[JUStringValidator alloc] init];
	[self addValidator:validator];

	return validator;
}

- (JUNumberValidator *)number
{
	JUNumberValidator *validator = [[JUNumberValidator alloc] init];
	[self addValidator:validator];

	return validator;
}

- (JUValidator *)object
{
	JUValidator *validator = [[JUValidator alloc] init];
	[self addValidator:validator];

	return validator;
}

- (JUDictionaryValidator * (^)())isDictionary
{
	return ^JUDictionaryValidator *() {
		return self.isClass([NSDictionary class]).dictionary;
	};
}
- (JUArrayValidator * (^)())isArray
{
	return ^JUArrayValidator *() {
		return self.isClass([NSArray class]).array;
	};
}
- (JUStringValidator * (^)())isString
{
	return ^JUStringValidator *() {
		return self.isClass([NSString class]).string;
	};
}
- (JUNumberValidator * (^)())isNumber
{
	return ^JUNumberValidator *() {
		return self.isClass([NSNumber class]).number;
	};
}


- (instancetype)and
{
	return self;
}
- (instancetype)ifOptionally
{
	JULogicValidator *validator = [JULogicValidator validatorWithType:JULogicValidatorTypeIf];
	return JUAddProxyValidator(validator);
}
- (JUValidator * (^)(void (^)(JUValidator *)))then
{
	JULogicValidator *validator = [JULogicValidator validatorWithType:JULogicValidatorTypeEndIf];

	JUArrayValidator *proxy = JUProxyValidator(validator);
	[self addValidator:proxy];

	return ^id (void (^setup)(JUValidator *)) {
		if(setup)
			setup(proxy);

		return proxy;
	};
}
- (JUValidator * (^)(void (^)(JUValidator *)))validate
{
	JUValidator *validator = [[self class] validatorWithName:nil];
	[self addValidator:validator];

	return ^id (void (^setup)(JUValidator *)) {
		setup(validator);
		return validator;
	};
}

- (JUValidator * (^)(BOOL (^)(id)))passesTest
{
	return ^id (BOOL (^block)(id)) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			@try
			{
				BOOL result = block(object);

				if(!result)
				{
					*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Custom test failed"]);
					return nil;
				}
			}
			@catch(NSException *e)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Block threw exception %@", e]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}


- (JUValidator * (^)(NSString *))message
{
	return ^JUValidator *(NSString *message) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			NSLog(@"%@", message);
			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

#pragma mark -
#pragma mark Object validation

- (JUValidator * (^)(Class))isClass
{
	return ^JUValidator *(Class class) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			if(![object isKindOfClass:class])
			{
				*error = JUMakeError(JUValidatorErrorInvalidClass, [NSString stringWithFormat:@"Expected class %@, but object had class %@", class, [object class]]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUValidator * (^)(NSString *))valueForKey
{
	return ^JUValidator *(NSString *key) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			id value = nil;

			@try
			{
				BOOL isKeyPath = ([key rangeOfString:@"."].location != NSNotFound);
				value = isKeyPath ? [object valueForKeyPath:key] : [object valueForKey:key];
			}
			@catch(NSException *e)
			{
				*error = JUMakeError(JUValidatorErrorInvalidKey, [NSString stringWithFormat:@"Expected value for key %@", key]);
				return nil;
			}

			return value;

		}];

		return JUAddProxyValidator(validator);
	};
}

- (JUValidator * (^)(id))isEqual
{
	return ^JUValidator *(id other) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			if(![object isEqual:other])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected object %@ to be equal to %@", object, other]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUValidator * (^)(id))isNotEqual
{
	return ^JUValidator *(id other) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			if([object isEqual:other])
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected object %@ not to be equal to %@", object, other]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUValidator * (^)(id))isIdentical
{
	return ^JUValidator *(id other) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			if(object != other)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected object %@ to be identical to %@", object, other]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUValidator * (^)(id))isNotIdentical
{
	return ^JUValidator *(id other) {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id (id object, NSError **error) {

			if(object == other)
			{
				*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected object %@ not to be identical to %@", object, other]);
				return nil;
			}

			return object;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUValidator * (^)())isNull
{
	return ^JUValidator *() {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id(id object, NSError **error) {

			if(object == [NSNull null])
				return object;

			*error = JUMakeError(JUValidatorErrorValidationFailed, [NSString stringWithFormat:@"Expected NSNull but got %@", [object class]]);
			return nil;

		}];

		return JUAddProxyValidator(validator);
	};
}
- (JUValidator * (^)())isNotNull
{
	return ^JUValidator *() {

		JUBlockValidator *validator = [JUBlockValidator validatorForClass:nil withBlock:^id(id object, NSError **error) {

			if(object != [NSNull null])
				return object;

			*error = JUMakeError(JUValidatorErrorValidationFailed, @"Expected non-NSNull");
			return nil;

		}];

		return JUAddProxyValidator(validator);
	};
}

#pragma mark -
#pragma mark Constructor

- (instancetype)init
{
	if((self = [super init]))
	{
		_validators = [[NSMutableArray alloc] init];
	}

	return self;
}

- (instancetype)initWithName:(NSString *)name
{
	if((self = [self init]))
	{
		_name = name;
	}

	return self;
}

- (instancetype)initWithValidator:(JUValidator *)otherValidator
{
	if((self = [self init]))
	{
		_wrappedValidator = otherValidator;
	}

	return self;
}

+ (instancetype)validatorWithName:(NSString *)name
{
	return [self validatorWithName:name andSetupBlock:nil];
}
+ (instancetype)validatorWithName:(NSString *)name andSetupBlock:(void (^)(JUValidator *))setup
{
	if(!name)
	{
		JUValidator *validator = [[self alloc] initWithName:name];

		if(setup)
			setup(validator);

		return validator;

	}

	[lookupLock lock];

	JUValidator *validator = [lookupTable objectForKey:name];
	if(!validator && setup)
	{
		validator = [[self alloc] initWithName:name];
		@try
		{
			setup(validator);
			[lookupTable setObject:validator forKey:name];
		}
		@catch(NSException *e)
		{
			[lookupLock unlock];
			validator = nil;

			@throw e;
		}
	}

	[lookupLock unlock];

	return validator;
}
+ (instancetype)validatorWrappingValidator:(JUValidator *)other
{
	return [[self alloc] initWithValidator:other];
}

@end
