//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPMethod.h"

#import <Foundation/Foundation.h>

@interface HTTPStubFile : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;

@property (nonatomic, readonly) HTTPMethod method;
@property (nonatomic, readonly, copy) NSString *path;

@property (nonatomic, readonly) NSInteger statusCode;

@property (nonatomic, readonly) NSDictionary *headers;
@property (nonatomic, readonly, copy) NSString *body;

@end
