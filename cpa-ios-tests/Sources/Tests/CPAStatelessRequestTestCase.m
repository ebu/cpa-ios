//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAStatelessRequest.h"
#import "HTTPStub.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSTimeInterval kConnectionTimeOut = 60;

@interface CPAStatelessRequestTestCase : XCTestCase

@end

@implementation CPAStatelessRequestTestCase

#pragma mark Setup and teardown

- (void)setUp
{
    [HTTPStub install];
}

- (void)tearDown
{
    [HTTPStub uninstall];
}

#pragma mark Tests

- (void)testRegisterClient
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Client registration request"];
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:authorizationProviderURL clientName:@"iOS Test" softwareIdentifier:@"ch.ebu.ios_test" softwareVersion:@"0.1" completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        XCTAssertEqualObjects(clientIdentifier, @"407");
        XCTAssertEqualObjects(clientSecret, @"f9f1c336a59219e05a59eecb40eb49eb");
        XCTAssertNil(error);
        [expectation fulfill];
    }];
    
    // TODO: Provide a wrapper which takes a cassette name as parameter and load / release it
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

@end
