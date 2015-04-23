//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HTTPStubFile.h"

@interface HTTPStubFile ()

@property (nonatomic) HTTPMethod method;
@property (nonatomic, copy) NSString *path;

@property (nonatomic) NSInteger statusCode;

@property (nonatomic) NSDictionary *headers;
@property (nonatomic) NSData *bodyData;

@end

@implementation HTTPStubFile

#pragma mark Object creation and destruction

- (instancetype)initWithFilePath:(NSString *)filePath
{
    NSParameterAssert(filePath);
    
    if (self = [super init]) {
        if (! [self parseFileAtPath:filePath]) {
            return nil;
        }
    }
    return self;
}

#pragma mark Parsing

- (BOOL)parseFileAtPath:(NSString *)filePath
{
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    if (! fileContents) {
        return NO;
    }
    
    // Separate metadata and body with an empty line
    NSArray *components = [fileContents componentsSeparatedByString:@"\n\n"];
    if ([components count] != 2) {
        return NO;
    }
    
    self.bodyData = [[components lastObject] dataUsingEncoding:NSUTF8StringEncoding];
    
    // Parse metadata
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSArray *metadataLines = [[components firstObject] componentsSeparatedByString:@"\n"];
    for (NSString *metadataLine in metadataLines) {
        // Lines containing : correspond to headers key : value
        if ([metadataLine rangeOfString:@": "].length != 0) {
            NSArray *lineComponents = [metadataLine componentsSeparatedByString:@": "];
            if ([lineComponents count] == 2) {
                NSString *headerName = [lineComponents firstObject];
                NSString *headerValue = [lineComponents lastObject];
                headers[headerName] = headerValue;
            }
        }
        // Response status
        else if ([metadataLine hasPrefix:@"HTTP"]) {
            NSArray *lineCompoments = [metadataLine componentsSeparatedByString:@" "];
            if ([lineCompoments count] >= 2) {
                self.statusCode = [[lineCompoments objectAtIndex:1] integerValue];
            }
        }
        // Otherwise method and path
        else {
            NSArray *lineComponents = [metadataLine componentsSeparatedByString:@" "];
            if ([lineComponents count] >= 2) {
                self.method = HTTPMethodForName([lineComponents firstObject]);
                if (self.method == HTTPMethodUnknown) {
                    return NO;
                }
                
                self.path = [lineComponents objectAtIndex:1];
            }
        }
    }
    self.headers = [NSDictionary dictionaryWithDictionary:headers];
    
    return YES;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; method: %@; path: %@; statusCode: %@; headers: %@>",
            [self class],
            self,
            NameForHTTPMethod(self.method),
            self.path,
            @(self.statusCode),
            self.headers];
}

@end
