//
// Created by Sidney Just on 20/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JUValidate.h"

@interface JUValidateDictionaryTests : XCTestCase
@end


@implementation JUValidateDictionaryTests
{

}

- (void)testCount
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.dictionary.countIs(4);
	}];

	NSDictionary *test1 = @{ @"a": @"b", @"c": @"d", @"e": @"f", @"g": @"h" };
	NSDictionary *test2 = @{ @"a": @(1) };

	NSError *error;
	XCTAssertTrue([validator validateObject:test1 error:&error], @"%@", error);
	XCTAssertNil(error);

	XCTAssertFalse([validator validateObject:test2 error:&error], @"%@", error);
	XCTAssertNotNil(error);
}

@end