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

#pragma mark NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    EBUToken *token = [EBUToken new];
    token.value = [aDecoder decodeObjectForKey:@"value"];
    token.domain = [aDecoder decodeObjectForKey:@"domain"];
    token.domainName = [aDecoder decodeObjectForKey:@"domainName"];
    token.authenticated = [aDecoder decodeBoolForKey:@"authenticated"];
    return token;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
    [aCoder encodeObject:self.domainName forKey:@"domainName"];
    [aCoder encodeBool:self.authenticated forKey:@"authenticated"];
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
