//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

// Types
typedef void (^CPAAuthorizationCompletionBlock)(NSError *error);

/**
 * A basic web browser to grab user credentials
 */
@interface CPAAuthorizationViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate>

/**
 * Create the browser using the specified verification URL, and supplying the given user code automatically
 */
- (instancetype)initWithVerificationURL:(NSURL *)verificationURL userCode:(NSString *)userCode NS_DESIGNATED_INITIALIZER;

/**
 * An optional block which gets called when the user finished authorization (whether access was accepted or rejected
 * can be found by checking the associated error)
 */
@property (nonatomic, copy, nullable) CPAAuthorizationCompletionBlock completionBlock;

@end

@interface CPAAuthorizationViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
