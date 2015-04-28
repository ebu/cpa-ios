//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPMethod.h"
#import "OHHTTPStubsResponse.h"

#import <Foundation/Foundation.h>

/**
 * Represent a stub. Stubs are expected in the Stubs directory of the test bundle. A stub is defined by creating a directory
 * containing two files:
 *   - a file called 'request' containing the request data (HTTP method, path, headers and JSON body), as
 *     follows:
 *       - On the first line, the HTTP method, followed by the path
 *       - On the following lines, headers given by Name: Value, one header per line
 *       - A blank line
 *       - The JSON body
 *   - a file called 'response' containing the response status code, headers and JSON body, as follows:
 *       - On the first line, the HTTP version, followed by the status code
 *       - On the following lines, headers given by Name: Value, one header per line
 *       - A blank line
 *       - The JSON body
 * The name of the folder is the name of the stub.
 *
 * The file format matches the one of Paw (https://luckymarmot.com/paw). It therefore suffices to create and run a request
 * with Paw, and to copy the raw request contents to 'request' and 'response' files put in a common folder to create
 * a new stub.
 */
@interface HTTPStub : NSObject

/**
 * Install the stub with the given name
 */
+ (void)installStubWithName:(NSString *)name;
+ (void)removeStubWithName:(NSString *)name;

/**
 * Remove all installed stubs
 */
+ (void)removeAllStubs;

/**
 * The stub name
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * Return YES iff the stub matches a request (HTTP method, path, headers and JSON body). The following headers might
 * differ and are omitted when comparing a request with a stub: Cookie, Connection, User-Agent, Content-Length, Host
 */
- (BOOL)matchesRequest:(NSURLRequest *)request;

/**
 * Return the corresponding OHHTTPStubsResponse
 */
- (OHHTTPStubsResponse *)response;

@end
