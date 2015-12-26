//
//  speeddate.m
//  speeddateTests
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <XCTest/XCTest.h>
#import "RevealRequest.h"
#import "UserParseHelper.h"
#import <Parse/Parse.h>

@interface speeddateTests : XCTestCase {
    
    UserParseHelper *testUser;
    UserParseHelper *testMatch;
}


@end

@implementation speeddateTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [self getUser];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testRevealRequest
{
    NSLog(@"Test USer: %@", testUser.nickname);
    NSLog(@"Test Match: %@", testMatch.nickname);
}

#pragma mark - Helper Methods

- (void)getUser
{
    NSString *userID = @"ovDKmA2OwE";
    NSString *matchID = @"OqGlWzfsYe";
    NSString *description = @"Get Test User and Test Match";
    XCTestExpectation *expectation = [self expectationWithDescription:description];
    
    PFQuery *userQuery = [UserParseHelper query];
    PFQuery *matchQuery = [UserParseHelper query];
    [userQuery getObjectInBackgroundWithId:userID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
            testUser = (UserParseHelper *)object;
        
            [matchQuery getObjectInBackgroundWithId:matchID block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (!error) {
                    testMatch = (UserParseHelper *)object;
                    
                    [expectation fulfill];
                }
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
