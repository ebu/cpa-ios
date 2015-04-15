//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAKeyboardInformation.h"

// This implementation has been borrowed from CoconutKit HLSKeyboardInformation (see https://github.com/defagos/CoconutKit)

@interface CPAKeyboardInformation ()

@property (nonatomic) CGRect beginFrame;
@property (nonatomic) CGRect endFrame;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) UIViewAnimationCurve animationCurve;

@end

static CPAKeyboardInformation *s_instance = nil;

@implementation CPAKeyboardInformation

#pragma mark Class methods

+ (instancetype)keyboardInformation
{
    return s_instance;
}

#pragma mark Object creation and destruction

- (instancetype)initWithUserInfo:(NSDictionary *)userInfo
{
    if (self = [super init]) {
        self.beginFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        self.endFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        self.animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntValue];
    }
    return self;
}

#pragma mark Notification callbacks

+ (void)keyboardWillShow:(NSNotification *)notification
{
    s_instance = [[CPAKeyboardInformation alloc] initWithUserInfo:[notification userInfo]];
}

+ (void)keyboardWillHide:(NSNotification *)notification
{
    s_instance = nil;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; beginFrame: %@; endFrame: %@; animationDuration: %f>",
            [self class],
            self,
            NSStringFromCGRect(self.beginFrame),
            NSStringFromCGRect(self.endFrame),
            self.animationDuration];
}

@end

__attribute__ ((constructor)) static void CPAKeyboardInformationInit(void)
{
    // Register for keyboard notifications. Note that when the keyboard is visible and the device is rotated,
    // we get a hide and a show notifications (keyboard with first orientation is dismissed, keyboard with
    // new orientation is displayed again)
    [[NSNotificationCenter defaultCenter] addObserver:[CPAKeyboardInformation class]
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[CPAKeyboardInformation class]
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
