//
// Created by Sidney Just on 16/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JUBlockValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);

@implementation JUBlockValidator
{
	Class _class;
	id (^_block)(id, NSError **);
}

- (id)evaluateWithObject:(id)object error:(NSError **)error
{
	if(_class && ![object isKindOfClass:_class])
	{
		if(error)
			*error = JUMakeError(JUValidatorErrorInvalidClass, [NSString stringWithFormat:@"Expected class %@, but received object of class %@", _class, [object class]]);

		return nil;
	}

	NSError *tmpError;
	id result = _block(object, &tmpError);

	if(!result && error)
		*error = tmpError;

	return result;
}

- (BOOL)validateObject:(id)object error:(NSError **)error
{
	if(_evaluateObject)
		return _evaluateObject(object, error);

	return [super validateObject:object error:error];
}


- (instancetype)initWithClass:(Class)class andBlock:(id (^)(id, NSError **))block
{
	if((self = [super init]))
	{
		_class = class;
		_block = block;
	}

	return self;
}

+ (JUBlockValidator *)validatorForClass:(Class)class withBlock:(id (^)(id, NSError **))block
{
	return [[JUBlockValidator alloc] initWithClass:class andBlock:block];
}

@end