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

#pragma mark Request conformance and response construction

- (BOOL)matchesRequest:(NSURLRequest *)request
{
    return HTTPMethodForName(request.HTTPMethod) == self.requestStubFile.method
        && [request.URL.path isEqualToString:self.requestStubFile.path];
}

- (OHHTTPStubsResponse *)response
{
    return [OHHTTPStubsResponse responseWithData:self.responseStubFile.bodyData
                                      statusCode:(int)self.responseStubFile.statusCode
                                         headers:self.responseStubFile.headers];
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

