//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPMethod.h"

#import <Foundation/Foundation.h>

/**
 * A stub file (see HTTPStub.h)
 */
@interface HTTPStubFile : NSObject

/**
 * Create an instance from a given file
 */
- (instancetype)initWithFilePath:(NSString *)filePath;

/**
 * The HTTP method, HTTPMethodUnknown if not found (e.g. if the file is a response)
 */
@property (nonatomic, readonly) HTTPMethod method;

/**
 * The resource path, nil if none (e.g. if the file is a response)
 */
@property (nonatomic, readonly, copy) NSString *path;

/**
 * The HTTP status code, 0 if none (e.g. if the file is a request)
 */
@property (nonatomic, readonly) NSInteger statusCode;

/**
 * The HTTP headers
 */
@property (nonatomic, readonly) NSDictionary *headers;

/**
 * The body data
 */
@property (nonatomic, readonly) NSData *bodyData;

@end
