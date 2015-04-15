//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAToken.h"

@interface CPAToken ()

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *domainName;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic) NSInteger lifetimeInSeconds;

@end

@implementation CPAToken

#pragma mark Object lifecycle

- (instancetype)initWithValue:(NSString *)value
                       domain:(NSString *)domain
                   domainName:(NSString *)domainName
                     userName:(NSString *)userName
            lifetimeInSeconds:(NSInteger)lifetimeInSeconds
{
    NSParameterAssert(value);
    NSParameterAssert(domain);
    NSParameterAssert(domainName);
    
    if (self = [super init]) {
        self.value = value;
        self.domain = domain;
        self.domainName = domainName;
        self.userName = userName;
        self.lifetimeInSeconds = lifetimeInSeconds;
    }
    return self;
}

#pragma mark Accessors and mutators

- (CPATokenType)type
{
    return (self.userName != nil) ? CPATokenTypeUser : CPATokenTypeClient;
}

#pragma mark NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    CPAToken *token = [CPAToken new];
    token.value = [aDecoder decodeObjectForKey:@"value"];
    token.domain = [aDecoder decodeObjectForKey:@"domain"];
    token.domainName = [aDecoder decodeObjectForKey:@"domainName"];
    token.userName = [aDecoder decodeObjectForKey:@"userName"];
    token.lifetimeInSeconds = [aDecoder decodeIntegerForKey:@"lifetimeInSeconds"];
    return token;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.value forKey:@"value"];
    [aCoder encodeObject:self.domain forKey:@"domain"];
    [aCoder encodeObject:self.domainName forKey:@"domainName"];
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeInteger:self.lifetimeInSeconds forKey:@"lifetimeInSeconds"];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; value: %@; domain: %@; domainName: %@; userName: %@; type: %@; lifetimeInSeconds: %@>",
            [self class],
            self,
            self.value,
            self.domain,
            self.domainName,
            self.userName,
            (self.type == CPATokenTypeClient) ? @"Client" : @"User",
            @(self.lifetimeInSeconds)];
}

@end
