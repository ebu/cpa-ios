//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPStub.h"

#import "HTTPStubFile.h"
#import "NSBundle+Tests.h"
#import "OHHTTPStubs.h"

@interface HTTPStub ()

@property (nonatomic) HTTPStubFile *requestStubFile;
@property (nonatomic) HTTPStubFile *responseStubFile;

@end

@implementation HTTPStub

#pragma mark Class methods

+ (NSArray *)HTTPStubs
{
    static NSArray *s_stubs;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        NSArray *stubDirectoryPaths = [[NSBundle testBundle] pathsForResourcesOfType:nil inDirectory:@"Stubs"];
        
        NSMutableArray *stubs = [NSMutableArray array];
        for (NSString *stubDirectoryPath in stubDirectoryPaths) {
            HTTPStub *stub = [[HTTPStub alloc] initWithDirectoryPath:stubDirectoryPath];
            if (stub) {
                [stubs addObject:stub];
            }
        }
        s_stubs = [NSArray arrayWithArray:stubs];
    });
    return s_stubs;
}

+ (void)install
{
    // Add a default handler so that if no stub is found no network connection is made instead
    [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
        return YES;
    } withStubResponse:^(NSURLRequest *request) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"No stub matches this request" };
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    
    for (HTTPStub *stub in [HTTPStub HTTPStubs]) {
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
            return [stub matchesRequest:request];
        } withStubResponse:^(NSURLRequest *request) {
            return [stub response];
        }];
    }
}

+ (void)uninstall
{
    [OHHTTPStubs removeAllStubs];
}

#pragma mark Object creation and destruction

- (instancetype)initWithDirectoryPath:(NSString *)directoryPath
{
    NSParameterAssert(directoryPath);
    
    if (self = [super init]) {
        NSString *requestFilePath = [directoryPath stringByAppendingPathComponent:@"request"];
        if (! requestFilePath) {
            return nil;
        }
        
        self.requestStubFile = [[HTTPStubFile alloc] initWithFilePath:requestFilePath];
        if (! self.requestStubFile) {
            return nil;
        }
        
        NSString *responseFilePath = [directoryPath stringByAppendingPathComponent:@"response"];
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
        && [request.URL.path isEqualToString:self.requestStubFile.path]
        && [self matchesBodyOfRequest:request]
        && [self matchesHeadersOFRequest:request];
}

- (BOOL)matchesHeadersOFRequest:(NSURLRequest *)request
{
    static NSArray *s_ignoredFields;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_ignoredFields = @[@"Cookie", @"Connection", @"User-Agent", @"Content-Length", @"Host"];
    });
    
    NSMutableDictionary *requestHeaders = [NSMutableDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    [requestHeaders removeObjectsForKeys:s_ignoredFields];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:self.requestStubFile.headers];
    [headers removeObjectsForKeys:s_ignoredFields];
    
    return [requestHeaders isEqualToDictionary:headers];
}

- (BOOL)matchesBodyOfRequest:(NSURLRequest *)request
{
    NSDictionary *requestBodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL];
    NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:self.requestStubFile.bodyData options:0 error:NULL];
    return [requestBodyDictionary isEqualToDictionary:bodyDictionary];
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

