//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPStub.h"

#import "HTTPStubFile.h"
#import "NSBundle+Tests.h"
#import "OHHTTPStubs.h"

static __weak id<OHHTTPStubsDescriptor> s_defaultStubDescriptor = nil;
static NSMutableDictionary *s_stubDescriptors = nil;

@interface HTTPStub ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic) HTTPStubFile *requestStubFile;
@property (nonatomic) HTTPStubFile *responseStubFile;

@end

@implementation HTTPStub

#pragma mark Class methods

+ (void)initialize
{
    if (self != [HTTPStub class]) {
        return;
    }
    
    s_stubDescriptors = [NSMutableDictionary dictionary];
}

+ (void)installStubWithName:(NSString *)name
{
    NSParameterAssert(name);
    
    HTTPStub *stub = [[HTTPStub alloc] initWithName:name];
    if (! stub) {
        return;
    }
    
    if (s_stubDescriptors.count == 0) {
        // Add a default handler so that if no stub is found no network connection is made instead. This default
        // handler must be installed first so that it is checked last
        s_defaultStubDescriptor = [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
            return YES;
        } withStubResponse:^(NSURLRequest *request) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"No stub matches this request" };
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorResourceUnavailable userInfo:userInfo];
            return [OHHTTPStubsResponse responseWithError:error];
        }];
    }
    
    // Install the stub
    id<OHHTTPStubsDescriptor> stubDescriptor = [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request) {
        return [stub matchesRequest:request];
    } withStubResponse:^(NSURLRequest *request) {
        return stub.response;
    }];
    
    // Weak references to stub descriptors suffice, see OHHTTPStubs.h
    s_stubDescriptors[name] = [NSValue valueWithNonretainedObject:stubDescriptor];
}

+ (void)removeStubWithName:(NSString *)name
{
    NSParameterAssert(name);
    
    id<OHHTTPStubsDescriptor> stubDescriptor = [s_stubDescriptors[name] pointerValue];
    if (! stubDescriptor) {
        return;
    }
    
    [OHHTTPStubs removeStub:stubDescriptor];
    [s_stubDescriptors removeObjectForKey:name];
    
    if (s_stubDescriptors.count == 0) {
        [OHHTTPStubs removeStub:s_defaultStubDescriptor];
    }
}

+ (void)removeAllStubs
{
    for (NSString *name in [s_stubDescriptors allKeys]) {
        [self removeStubWithName:name];
    }
}

#pragma mark Object creation and destruction

- (instancetype)initWithName:(NSString *)name
{
    NSParameterAssert(name);
    
    if (self = [super init]) {
        self.name = name;
        
        NSString *stubDirectoryPath = [[NSBundle testBundle] pathForResource:name ofType:nil inDirectory:@"Stubs"];
        if (! stubDirectoryPath) {
            return nil;
        }
        
        NSString *requestFilePath = [stubDirectoryPath stringByAppendingPathComponent:@"request"];
        self.requestStubFile = [[HTTPStubFile alloc] initWithFilePath:requestFilePath];
        if (! self.requestStubFile) {
            return nil;
        }
        
        NSString *responseFilePath = [stubDirectoryPath stringByAppendingPathComponent:@"response"];
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
        && [self matchesHeadersOfRequest:request];
}

- (BOOL)matchesHeadersOfRequest:(NSURLRequest *)request
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
    return [NSString stringWithFormat:@"<%@: %p; name: %@; requestStubFile: %@; responseStubFile: %@>",
            [self class],
            self,
            self.name,
            self.requestStubFile,
            self.responseStubFile];
}

@end

