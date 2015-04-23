//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPMethod.h"

#import <Foundation/Foundation.h>

@interface HTTPStub : NSObject

+ (instancetype)HTTPStubWithName:(NSString *)name;

- (instancetype)initWithName:(NSString *)name;

@property (nonatomic, readonly) HTTPMethod method;
@property (nonatomic, readonly, copy) NSString *path;

@property (nonatomic, readonly) NSInteger statusCode;

@property (nonatomic, readonly) NSDictionary *requestHeaders;
@property (nonatomic, readonly, copy) NSString *requestBody;

@property (nonatomic, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly, copy) NSString *responseBody;

@end

@interface HTTPStub (JSONExtensions)

@property (nonatomic, readonly) NSDictionary *requestJSONBody;
@property (nonatomic, readonly) NSDictionary *responseJSONBody;

@end
