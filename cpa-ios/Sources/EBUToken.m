//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUToken.h"

@interface EBUToken ()

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, getter=isAuthenticated) BOOL authenticated;

@end

@implementation EBUToken

#pragma mark Object lifecycle

- (instancetype)initWithValue:(NSString *)value domain:(NSString *)domain
{
    NSParameterAssert(value);
    NSParameterAssert(domain);
    
    if (self = [super init]) {
        self.value = value;
        self.domain = domain;
    }
    return self;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; value: %@; domain: %@; domainName: %@; authenticated: %@>",
            [self class],
            self,
            self.value,
            self.domain,
            self.domainName,
            self.authenticated ? @"YES" : @"NO"];
}

@end
