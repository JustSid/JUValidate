//
//  JUValidateTests.m
//  JUValidateTests
//
//  Created by Sidney Just on 16/07/2016.
//  Copyright © 2016 Sidney Just. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JUValidate.h"

@interface JUValidateTests : XCTestCase

@end

@implementation JUValidateTests

- (void)testExample
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.isClass([NSDictionary class]);

	}];

	NSDictionary *dictionary = @{};
	NSArray *array = @[];

	NSError *error = nil;
	BOOL result = [validator validateObject:dictionary error:&error];

	XCTAssertTrue(result, @"validation must succeed, error %@", error);
	XCTAssertNil(error);

	error = nil;
	result = [validator validateObject:array error:&error];

	XCTAssertFalse(result, @"validation must not succeed");
	XCTAssertNotNil(error);
}

- (void)testKeyPaths
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.valueForKey(@"test").isClass([NSNumber class]);
		validator.valueForKey(@"array").isClass([NSArray class]);
	 	validator.valueForKey(@"test").isNotNull();

	}];

	NSDictionary *dictionary = @{ @"test" : @1, @"array" : @[] };

	NSError *error = nil;
	BOOL result = [validator validateObject:dictionary error:&error];

	XCTAssertTrue(result, @"validation must succeed, error %@", error);
	XCTAssertNil(error);
}

- (void)testConditionals
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {

		validator.dictionary.ifOptionally.objectForKey(@"test").then(^(JUValidator *validator) {

			validator.isClass([NSNumber class]);

		});

	}];

	NSDictionary *test1 = @{ @"test": @(1) };
	NSDictionary *test2 = @{ @"non-test": @(1) };
	NSDictionary *test3 = @{ @"test": @"foo" };

	NSError *error;

	XCTAssertTrue([validator validateObject:test1 error:&error], @"%@", error);
	XCTAssertNil(error);

	XCTAssertTrue([validator validateObject:test2 error:&error], @"%@", error);
	XCTAssertNil(error);

	XCTAssertFalse([validator validateObject:test3 error:&error], @"%@", error);
	XCTAssertNotNil(error);
}

@end
