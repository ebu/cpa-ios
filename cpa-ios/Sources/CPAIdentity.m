//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAIdentity.h"

@interface CPAIdentity ()

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *secret;

@end

@implementation CPAIdentity

#pragma mark Object lifecycle

- (instancetype)initWithIdentifier:(NSString *)identifier
                            secret:(NSString *)secret
{
    NSParameterAssert(identifier);
    NSParameterAssert(secret);
    
    if (self = [super init]) {
        self.identifier = identifier;
        self.secret = secret;
    }
    return self;
}

#pragma NSCoding protocol

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    CPAIdentity *identity = [CPAIdentity new];
    identity.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    identity.secret = [aDecoder decodeObjectForKey:@"secret"];
    return identity;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.secret forKey:@"secret"];
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; identifier: %@; secret: %@>",
            [self class],
            self,
            self.identifier,
            self.secret];
}

@end
