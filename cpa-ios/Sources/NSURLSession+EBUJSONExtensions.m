//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSURLSession+EBUJSONExtensions.h"

#import "EBUErrors+Private.h"

@implementation NSURLSession (EBUJSONExtensions)

- (NSURLSessionDataTask *)JSONDictionaryTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error))completionHandler
{
    return [self dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionHandler ? completionHandler(nil, response, error) : nil;
                return;
            }
            
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            if (! responseJSON || ! [responseJSON isKindOfClass:[NSDictionary class]]) {
                NSError *parsingError = EBUErrorFromCode(EBUAuthenticationErrorInvalidResponse);
                completionHandler ? completionHandler(nil, response, parsingError) : nil;
                return;
            }
            
            NSDictionary *responseDictionary = responseJSON;

            // Deal with errors which might have been returned in the response JSON
            NSString *errorIdentifier = responseDictionary[@"error"] ?: responseDictionary[@"reason"];
            if (errorIdentifier) {
                NSError *responseError = EBUErrorFromIdentifier(errorIdentifier);
                completionHandler ? completionHandler(nil, response, responseError) : nil;
                return;
            }
            
            completionHandler ? completionHandler(responseDictionary, response, nil) : nil;
        });
    }];
}

@end
