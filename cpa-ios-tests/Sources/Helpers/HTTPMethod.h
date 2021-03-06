//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

// HTTP methods
typedef NS_ENUM(NSInteger, HTTPMethod) {
    HTTPMethodUnknown,
    HTTPMethodGET,
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodDELETE
};

/**
 * Conversion between HTTPMethod enum values and associated string representations
 */
NSString *NameForHTTPMethod(HTTPMethod method);
HTTPMethod HTTPMethodForName(NSString *name);
