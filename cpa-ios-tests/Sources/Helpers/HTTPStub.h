//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPMethod.h"
#import "OHHTTPStubsResponse.h"

#import <Foundation/Foundation.h>

@interface HTTPStub : NSObject

+ (instancetype)HTTPStubWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

- (BOOL)matchesRequest:(NSURLRequest *)request;
- (OHHTTPStubsResponse *)response;

@end
