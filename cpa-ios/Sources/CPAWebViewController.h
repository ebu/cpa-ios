//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

// Types
typedef void (^CPAWebViewControllerCallbackBlock)(NSURL *callbackURL);

// When a request having this scheme is encountered, the callback block will be called
extern NSString * const CPAWebViewCallbackURLScheme;

/**
 * A basic web browser
 */
@interface CPAWebViewController : UIViewController <UIWebViewDelegate, WKNavigationDelegate>

/**
 * Create the browser using the specified request
 */
- (instancetype)initWithRequest:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

/**
 * The initial request
 */
@property (nonatomic, readonly) NSURLRequest *request;

/**
 * An optional block which gets called for URLs with the CPAWebViewCallbackURLScheme scheme
 */
@property (nonatomic, copy) CPAWebViewControllerCallbackBlock callbackURLBlock;

@end

@interface CPAWebViewController (UnavailableMethods)

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithBundle:(NSBundle *)bundle NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
