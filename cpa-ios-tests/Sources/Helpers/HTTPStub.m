//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPStub.h"

#import "HTTPStubFile.h"
#import "NSBundle+Tests.h"

@interface HTTPStub ()

@property (nonatomic) HTTPStubFile *requestStubFile;
@property (nonatomic) HTTPStubFile *responseStubFile;

@end

@implementation HTTPStub

#pragma mark Class methods

+ (instancetype)HTTPStubWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

#pragma mark Object creation and destruction

- (instancetype)initWithName:(NSString *)name
{
    NSParameterAssert(name);
    
    if (self = [super init]) {
        NSString *requestFilePath = [[NSBundle testBundle] pathForResource:name ofType:@"request"];
        if (! requestFilePath) {
            return nil;
        }
        
        self.requestStubFile = [[HTTPStubFile alloc] initWithFilePath:requestFilePath];
        if (! self.requestStubFile) {
            return nil;
        }
        
        NSString *responseFilePath = [[NSBundle testBundle] pathForResource:name ofType:@"response"];
        if (! responseFilePath) {
            return nil;
        }
        
        self.responseStubFile = [[HTTPStubFile alloc] initWithFilePath:responseFilePath];
        if (! self.responseStubFile) {
            return nil;
        }
    }
    return self;
}

#pragma mark Accessors and mutators

- (HTTPMethod)method
{
    return self.requestStubFile.method;
}

- (NSString *)path
{
    return self.requestStubFile.path;
}

- (NSInteger)statusCode
{
    return self.responseStubFile.statusCode;
}

- (NSDictionary *)requestHeaders
{
    return self.requestStubFile.headers;
}

- (NSString *)requestBody
{
    return self.requestStubFile.body;
}

- (NSDictionary *)responseHeaders
{
    return self.responseStubFile.headers;
}

- (NSString *)responseBody
{
    return self.responseStubFile.body;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; requestStubFile: %@; responseStubFile: %@>",
            [self class],
            self,
            self.requestStubFile,
            self.responseStubFile];
}

@end

@implementation HTTPStub (JSONExtensions)

- (NSDictionary *)requestJSONBody
{
    NSData *data = [self.requestBody dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
}

- (NSDictionary *)responseJSONBody
{
    NSData *data = [self.responseBody dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
}

@end

