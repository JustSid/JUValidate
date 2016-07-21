//
// Created by Sidney Just on 19/07/2016.
// Copyright (c) 2016 Sidney Just. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JUValidate.h"

@interface JUValidateNumberTests : XCTestCase
@end

@implementation JUValidateNumberTests
{

}

#define InsertNumbers() \
	NSNumber *bTrue = [NSNumber numberWithBool:YES]; \
	NSNumber *bFalse = [NSNumber numberWithBool:NO]; \
	NSNumber *cNum = [NSNumber numberWithChar:INT8_MIN]; \
	NSNumber *sNum = [NSNumber numberWithShort:INT16_MIN]; \
	NSNumber *iNum = [NSNumber numberWithInt:INT32_MIN]; \
	NSNumber *lNum = [NSNumber numberWithLong:INT64_MIN]; \
	NSNumber *llNum = [NSNumber numberWithLongLong:INT64_MIN]; \
	NSNumber *ucNum = [NSNumber numberWithUnsignedChar:UINT8_MAX]; \
	NSNumber *usNum = [NSNumber numberWithUnsignedShort:UINT16_MAX]; \
	NSNumber *uiNum = [NSNumber numberWithUnsignedInt:UINT32_MAX]; \
	NSNumber *ulNum = [NSNumber numberWithUnsignedLong:UINT64_MAX]; \
	NSNumber *ullNum = [NSNumber numberWithUnsignedLongLong:UINT64_MAX]; \
	NSNumber *fNum = [NSNumber numberWithFloat:42.5f]; \
	NSNumber *dNum = [NSNumber numberWithDouble:42.85f]

- (void)testBool
{
	InsertNumbers();

	JUValidator *isBoolValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isBoolean();
	}];

	JUValidator *isTrueValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isTrue();
	}];

	JUValidator *isFalseValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isFalse();
	}];

	{
		NSError *error;
		XCTAssertTrue([isBoolValidator validateObject:bTrue error:&error], @"%@", error);
		XCTAssertNil(error);

		XCTAssertTrue([isTrueValidator validateObject:bTrue error:&error], @"%@", error);
		XCTAssertNil(error);

		XCTAssertFalse([isTrueValidator validateObject:bFalse error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
	{
		NSError *error;
		XCTAssertTrue([isBoolValidator validateObject:bFalse error:&error], @"%@", error);
		XCTAssertNil(error);

		XCTAssertFalse([isFalseValidator validateObject:bTrue error:&error], @"%@", error);
		XCTAssertNotNil(error);

		error = nil;

		XCTAssertTrue([isFalseValidator validateObject:bFalse error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		// BOOL is signed char
		NSError *error;
		XCTAssertTrue([isBoolValidator validateObject:cNum error:&error], @"%@", error);
		XCTAssertNil(error);
	}

#define CheckNonBoolType(type) \
	do { \
		NSError *error; \
		XCTAssertFalse([isBoolValidator validateObject:type error:&error], @"%@", error); \
		XCTAssertNotNil(error); \
		error = nil; \
		\
		XCTAssertFalse([isBoolValidator validateObject:type error:&error], @"%@", error); \
		XCTAssertNotNil(error); \
		error = nil; \
		\
		XCTAssertFalse([isTrueValidator validateObject:type error:&error], @"%@", error); \
		XCTAssertNotNil(error); \
		error = nil; \
	} while(0)

	CheckNonBoolType(sNum);
	CheckNonBoolType(iNum);
	CheckNonBoolType(lNum);
	CheckNonBoolType(llNum);

	CheckNonBoolType(ucNum);
	CheckNonBoolType(usNum);
	CheckNonBoolType(uiNum);
	CheckNonBoolType(ulNum);
	CheckNonBoolType(ullNum);

	CheckNonBoolType(fNum);
	CheckNonBoolType(dNum);
#undef CheckNonBoolType
}

- (void)testChar
{
	InsertNumbers();

	JUValidator *isCharValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isChar();
	}];

	{
		NSError *error;
		XCTAssertTrue([isCharValidator validateObject:cNum error:&error], @"%@", error);
		XCTAssertNil(error);

		XCTAssertTrue([isCharValidator validateObject:bTrue error:&error], @"%@", error);
		XCTAssertNil(error);

		XCTAssertTrue([isCharValidator validateObject:bFalse error:&error], @"%@", error);
		XCTAssertNil(error);
	}

#define CheckNonCharType(type) \
	do { \
		NSError *error; \
		XCTAssertFalse([isCharValidator validateObject:type error:&error], @"%@", error); \
		XCTAssertNotNil(error); \
	} while(0)

	CheckNonCharType(sNum);
	CheckNonCharType(iNum);
	CheckNonCharType(lNum);
	CheckNonCharType(llNum);

	CheckNonCharType(ucNum);
	CheckNonCharType(usNum);
	CheckNonCharType(uiNum);
	CheckNonCharType(ulNum);
	CheckNonCharType(ullNum);

	CheckNonCharType(fNum);
	CheckNonCharType(dNum);
#undef CheckNonCharType
}

#define __CheckNonType(type, exclusion) \
	do { \
		if([exclusion compare:type] != NSOrderedDescending) \
			break; \
		NSError *error; \
		XCTAssertFalse([validator validateObject:type error:&error], @"%@", error); \
		XCTAssertNotNil(error); \
	} while(0)

#define BuildTypeTest(name, type, floatingPoint) \
	- (void)test##name \
	{ \
		InsertNumbers(); \
		JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) { \
			validator.number.is##name(); \
		}]; \
		JUValidator *floatValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) { \
			validator.number.isFloatingPoint(); \
		}]; \
		JUValidator *integerValidator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) { \
			validator.number.isInteger(); \
		}]; \
		{ \
			NSError *error; \
			XCTAssertTrue([validator validateObject:type error:&error], @"%@", error); \
			XCTAssertNil(error); \
		} \
		if(floatingPoint) \
		{ \
			NSError *error; \
			XCTAssertTrue([floatValidator validateObject:type error:&error], @"%@", error); \
			XCTAssertNil(error); \
			XCTAssertFalse([integerValidator validateObject:type error:&error], @"%@", error); \
			XCTAssertNotNil(error); \
		} \
		else \
		{ \
			NSError *error; \
			XCTAssertTrue([integerValidator validateObject:type error:&error], @"%@", error); \
			XCTAssertNil(error); \
			XCTAssertFalse([floatValidator validateObject:type error:&error], @"%@", error); \
			XCTAssertNotNil(error); \
		} \
		__CheckNonType(bTrue, type); \
		__CheckNonType(bFalse, type); \
		\
		__CheckNonType(cNum, type); \
		__CheckNonType(sNum, type); \
		__CheckNonType(iNum, type); \
		__CheckNonType(lNum, type); \
		__CheckNonType(llNum, type); \
 		\
		__CheckNonType(ucNum, type); \
		__CheckNonType(usNum, type); \
		__CheckNonType(uiNum, type); \
		__CheckNonType(ulNum, type); \
		__CheckNonType(ullNum, type); \
 		\
		__CheckNonType(fNum, type); \
		__CheckNonType(dNum, type); \
	}

BuildTypeTest(Short, sNum, NO)
BuildTypeTest(Int, iNum, NO)
BuildTypeTest(Long, lNum, NO)
BuildTypeTest(LongLong, llNum, NO)

BuildTypeTest(Float, fNum, YES)
BuildTypeTest(Double, dNum, YES)

- (void)testLessThan
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isLessThan(@(42));
	}];

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(41) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(-80) error:&error], @"%@", error);
		XCTAssertNil(error);
	}

	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(42) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(80) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
}

- (void)testMoreThan
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isMoreThan(@(42));
	}];

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(43) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(80) error:&error], @"%@", error);
		XCTAssertNil(error);
	}

	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(42) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(-80) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
}

- (void)testLessOrEqual
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isLessOrEqualTo(@(42));
	}];

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(41) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(-80) error:&error], @"%@", error);
		XCTAssertNil(error);
	}

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(42) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(80) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
}

- (void)testMoreOrEqual
{
	JUValidator *validator = [JUValidator validatorWithName:nil andSetupBlock:^(JUValidator *validator) {
		validator.number.isMoreOrEqualTo(@(42));
	}];

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(43) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(80) error:&error], @"%@", error);
		XCTAssertNil(error);
	}

	{
		NSError *error;
		XCTAssertTrue([validator validateObject:@(42) error:&error], @"%@", error);
		XCTAssertNil(error);
	}
	{
		NSError *error;
		XCTAssertFalse([validator validateObject:@(-80) error:&error], @"%@", error);
		XCTAssertNotNil(error);
	}
}

@end