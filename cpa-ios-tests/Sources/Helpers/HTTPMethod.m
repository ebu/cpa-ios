//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HTTPMethod.h"

static NSDictionary *HTTPMethodNames(void)
{
    static NSDictionary *s_names;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @(HTTPMethodGET) : @"GET",
                     @(HTTPMethodPOST) : @"POST",
                     @(HTTPMethodPUT) : @"PUT",
                     @(HTTPMethodDELETE) : @"DELETE" };
    });
    return s_names;
}

NSString *NameForHTTPMethod(HTTPMethod method)
{
    return HTTPMethodNames()[@(method)];
}

HTTPMethod HTTPMethodForName(NSString *name)
{
    return [[[HTTPMethodNames() allKeysForObject:name] firstObject] integerValue];
}
