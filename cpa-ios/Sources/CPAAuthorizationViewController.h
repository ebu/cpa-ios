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
typedef void (^CPAAuthorizationCompletionBlock)(BOOL isFinished, NSError *error);

/**
 * A basic web browser to grab user credentials
 */
@interface CPAAuthorizationViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate>

/**
 * Create the browser using the specified verification URL, and supplying the given user code automatically. An optional
 * block can be provided. This block is:
 *   - called with isFinished = YES when the authorization process finishes, whether the user accepts or rejects the application
 *     (check the error property)
 *   - called with isFinished = NO if the view controller was dismissed before the authorization process could finish
 */
- (instancetype)initWithVerificationURL:(NSURL *)verificationURL
                               userCode:(NSString *)userCode
                        completionBlock:(nullable CPAAuthorizationCompletionBlock)completionBlock NS_DESIGNATED_INITIALIZER;

/**
 * An optional block which gets called at the
 
 user finishes authorization (whether access was accepted or rejected
 * can be found by checking the associated error) with isFinished. If the view controller is dismissed before authorization finishes,
 * the isFinished block parameter is set to NO, otherwise YES
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
