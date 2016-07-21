//
// Created by Sidney Just on 18/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JUValidate.h"

@interface JUValidateArrayTests : XCTestCase
@end

@implementation JUValidateArrayTests
{

}

- (void)testCount
{
	JUValidator *validatorFixedCount = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSArray class]);
		validator.array.countIs(4);

	}];

	JUValidator *validatorRange = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSArray class]);
		validator.array.countIsInRange(2, 4);
		validator.array.countIsMoreThan(1).and.countIsLessThan(5);

	}];

	XCTAssertNotNil(validatorFixedCount);
	XCTAssertNotNil(validatorRange);

	NSArray *array1 = @[ @(1), @(2), @(3), @(4) ];
	NSArray *array2 = @[ ];
	NSArray *array3 = @[ @(1), @(2) ];

	NSError *error = nil;

	XCTAssertTrue([validatorFixedCount validateObject:array1 error:&error], @"%@", error);
	error = nil;

	XCTAssertTrue([validatorRange validateObject:array1 error:&error], @"%@", error);
	error = nil;
	XCTAssertTrue([validatorRange validateObject:array3 error:&error], @"%@", error);
	error = nil;

	XCTAssertFalse([validatorFixedCount validateObject:array2 error:&error], @"%@", error);
	error = nil;
	XCTAssertFalse([validatorFixedCount validateObject:array3 error:&error], @"%@", error);
	error = nil;

	XCTAssertFalse([validatorRange validateObject:array2 error:&error], @"%@", error);
	error = nil;
}

- (void)testAccess
{
	JUValidator *validator1 = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSArray class]);
		validator.array.objectAtIndex(0).isClass([NSNumber class]);
		validator.array.objectAtIndex(2).isClass([NSString class]);
		validator.array.objectAtIndex(2).string.lengthIs(5);

	}];

	JUValidator *validator2 = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSArray class]);
		validator.array.containsObject(@"Hello");
		validator.array.containsObject(@YES);

	}];

	NSArray *array = @[ @YES, @NO, @"Hello" ];
	NSError *error;

	XCTAssertTrue([validator1 validateObject:array error:&error], @"%@", error);
	error = nil;

	XCTAssertTrue([validator2 validateObject:array error:&error], @"%@", error);
	error = nil;
}

- (NSDictionary *)makeTestObject
{
	int number = arc4random_uniform(100);
	return @{ @"name": @"Hello World", @"value": @(number), @"id": [[NSUUID UUID] UUIDString] };
}

- (NSDictionary *)makeInvalidTestObject
{
	int number = arc4random_uniform(100);
	return @{ @"value": @"Hello World", @"name": @(number), @"id": [[NSUUID UUID] UUIDString] };
}

- (void)testEach
{
	JUValidator *validator1 = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSArray class]);
		validator.array.each(^(JUValidator *validator) {

			validator.dictionary.objectForKey(@"name").isClass([NSString class]);
			validator.dictionary.objectForKey(@"value").isClass([NSNumber class]);
			validator.dictionary.objectForKey(@"id").string.isUUID();

		});

	}];

	NSArray *array1 = @[ [self makeTestObject],
		[self makeTestObject],
		[self makeTestObject],
		[self makeTestObject] ];

	NSArray *array2 = @[ [self makeTestObject],
		[self makeInvalidTestObject],
		[self makeTestObject],
		[self makeInvalidTestObject] ];

	NSError *error;

	XCTAssertTrue([validator1 validateObject:array1 error:&error], @"%@", error);
	error = nil;

	XCTAssertFalse([validator1 validateObject:array2 error:&error], @"%@", error);
	XCTAssertNotNil(error);

	NSArray *subErrors = [[error userInfo] objectForKey:JUDetailedErrorsKey];

	XCTAssertNotNil(subErrors);
	XCTAssertEqual([subErrors count], 4, @"Two failed tests * two objects == 4 errors to be produced");
}

@end
