//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAStatelessRequest.h"
#import "NSBundle+Tests.h"
#import "VCR.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSTimeInterval kConnectionTimeOut = 60;

@interface CPAStatelessRequestTestCase : XCTestCase

@end

@implementation CPAStatelessRequestTestCase

#pragma mark Tests

- (void)testExample
{
    NSURL *cassetteURL = [[NSBundle testBundle] URLForResource:@"cassette_client_token_success" withExtension:@"json"];
    [VCR loadCassetteWithContentsOfURL:cassetteURL];
    [VCR start];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Client registration request"];
    
    NSURL *authorizationProviderURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:authorizationProviderURL clientName:@"a" softwareIdentifier:@"b" softwareVersion:@"c" completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        if (error) {
            XCTFail(@"timeout error: %@", error);
        }
        [VCR stop];
        [expectation fulfill];
    }];
    
    // TODO: Provide a wrapper which takes a cassette name as parameter and load / release it
    [self waitForExpectationsWithTimeout:kConnectionTimeOut handler:^(NSError *error) {
        [VCR stop];
    }];
}

@end
