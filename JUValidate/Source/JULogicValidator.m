//
// Created by Sidney Just on 19/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import "JULogicValidator.h"

extern NSError *JUMakeError(JUValidatorError code, NSString *reason);

@implementation JULogicValidator
{

}

- (void)addValidator:(JUValidator *)validator
{
	if(_type == JULogicValidatorTypeIf)
	{
		if([[self nextValidators] count])
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"JULogicValidator only supports one child" userInfo:nil];
	}

	[super addValidator:validator];
}

- (JULogicValidator *)findEndValidator:(JUValidator *)start
{
	NSArray<JUValidator *> *validators = [start nextValidators];
	if([validators count] == 0)
		return nil;

	JUValidator *next = [validators firstObject];

	if([next isKindOfClass:[JULogicValidator class]])
	{
		JULogicValidator *logicValidator = (JULogicValidator *)next;

		if([logicValidator type] == JULogicValidatorTypeEndIf)
			return logicValidator;
	}

	return [self findEndValidator:next];
}


- (id)evaluateWithObject:(id)object error:(NSError **)error
{
	return object;
}

- (id)evaluateValidator:(JUValidator *)validator withObject:(id)object error:(NSError **)error
{
	return [validator evaluateWithObject:object error:error];
}


- (BOOL)validateObject:(id)object error:(NSError **)error
{
	if(_type == JULogicValidatorTypeNop || _type == JULogicValidatorTypeEndIf)
		return [super validateObject:object error:error];

	JULogicValidator *endValidator = [self findEndValidator:self];
	if(!endValidator)
	{
		*error = JUMakeError(JUValidateErrorInvalidLogic, @"if() validator not terminated with then()");
		return NO;
	}

	JUValidator *nextValidator = [[self nextValidators] firstObject];

	NSError *innerError;
	id value = object;

	while(nextValidator != endValidator)
	{
		value = [self evaluateValidator:nextValidator withObject:value error:&innerError];
		if(!value)
			break;

		nextValidator = [[nextValidator nextValidators] firstObject];
	}

	if(!value)
		return YES;

	return [nextValidator validateObject:value error:error];
}

- (instancetype)initWithType:(JULogicValidatorType)type
{
	if((self = [super init]))
	{
		_type = type;
	}

	return self;
}

+ (instancetype)validatorWithType:(JULogicValidatorType)type
{
	return [(JULogicValidator *)[self alloc] initWithType:type];
}

@end