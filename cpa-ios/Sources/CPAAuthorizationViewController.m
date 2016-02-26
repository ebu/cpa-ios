//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// Most of this implementation has been borrowed from CoconutKit HLSWebViewController (see https://github.com/defagos/CoconutKit)

#import "CPAAuthorizationViewController.h"

#import "CPAErrors+Private.h"
#import "CPAKeyboardInformation.h"
#import "NSBundle+CPAExtensions.h"

static void *s_KVOContext = &s_KVOContext;

static NSString * const CPAWebViewCallbackURLScheme = @"cpacred";

static const NSTimeInterval CPAWebViewFadeAnimationDuration = 0.3;

// Static functions
static NSURL *CPAFullVerificationURL(NSURL *verificationURL, NSString *userCode);
static NSError *CPAErrorFromCallbackURL(NSURL *callbackURL);

@interface CPAAuthorizationViewController ()

@property (nonatomic) NSURLRequest *request;
@property (nonatomic) NSURL *currentURL;
@property (nonatomic) NSError *currentError;

@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) WKWebView *errorWebView;

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goBackBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *goForwardBarButtonItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *refreshBarButtonItem;

@property (nonatomic) NSArray *normalToolbarItems;
@property (nonatomic) NSArray *loadingToolbarItems;

@end

@implementation CPAAuthorizationViewController {
@private
    CGFloat _progress;
    BOOL _isFinished;
}

#pragma mark Object lifecycle

- (instancetype)initWithVerificationURL:(NSURL *)verificationURL
                               userCode:(NSString *)userCode
                        completionBlock:(CPAAuthorizationCompletionBlock)completionBlock
{
    NSParameterAssert(verificationURL);
    NSParameterAssert(userCode);
    
    if (self = [super initWithNibName:@"CPAAuthorizationViewController" bundle:[NSBundle cpa_resourceBundle]]) {
        NSURL *fullURL = CPAFullVerificationURL(verificationURL, userCode);
        self.request = [NSURLRequest requestWithURL:fullURL];
        self.completionBlock = completionBlock;
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [self doesNotRecognizeSelector:_cmd];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc
{
    @try {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
    @catch (NSException *exception) {}
}

#pragma mark Accessors and mutators

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (isless(progress, 0.f)) {
        _progress = 0.f;
    }
    else if (isgreater(progress, 1.f)) {
        _progress = 1.f;
    }
    else {
        _progress = progress;
    }
    
    if (_progress == 0.f) {
        if (animated) {
            [UIView animateWithDuration:CPAWebViewFadeAnimationDuration animations:^{
                self.progressView.alpha = 1.f;
            }];
        }
        else {
            self.progressView.alpha = 1.f;
        }
    }
    
    // Never animated
    [self.progressView setProgress:_progress animated:animated];
    
    if (_progress == 1.f) {
        if (animated) {
            [UIView animateWithDuration:CPAWebViewFadeAnimationDuration animations:^{
                self.progressView.alpha = 0.f;
            } completion:^(BOOL finished) {
                // Reset the progress bar
                self.progressView.progress = 0.f;
            }];
        }
        else {
            self.progressView.alpha = 0.f;
        }
    }
}

- (CGFloat)progress
{
    return _progress;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // WKWebView cannot be instantiated in nibs or storyboards. Do it manually
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.alpha = 0.f;
    webView.navigationDelegate = self;
    [webView loadRequest:self.request];
    
    // Progress information is available from WKWebView
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:s_KVOContext];
    
    // Scroll view content insets are adjusted automatically, but only for the scroll view at index 0. This
    // is the main content web view, we therefore put it at index 0
    [self.view insertSubview:webView atIndex:0];
    self.webView = webView;
    
    WKWebView *errorWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    errorWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    errorWebView.alpha = 0.f;
    errorWebView.navigationDelegate = self;
    errorWebView.userInteractionEnabled = NO;
    
    NSBundle *resourceBundle = [NSBundle cpa_resourceBundle];
    
    // WKWebView cannot load file URLs, except in the temporary directory, see
    //   http://stackoverflow.com/questions/24882834/wkwebview-not-working-in-ios-8-beta-4
    // As a workaround, copy the whole resource bundle to the temporary directory, and load pages from there. Since there are not so many
    // resources, copying the whole bundle does not harm
    //
    // TODO: Remove when a fix is available
    NSString *temporaryResourceBundlePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:CPAResourcesBundleName] stringByAppendingPathComponent:@"bundle"];
    
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:temporaryResourceBundlePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:temporaryResourceBundlePath error:NULL];
        }
        
        NSString *resourceBundlePath = [[NSBundle cpa_resourceBundle] bundlePath];
        [[NSFileManager defaultManager] copyItemAtPath:resourceBundlePath toPath:temporaryResourceBundlePath error:NULL];
    });
    
    NSURL *errorHTMLFileURL = [resourceBundle URLForResource:@"CPAWebViewControllerErrorTemplate" withExtension:@"html"];
    [errorWebView loadRequest:[NSURLRequest requestWithURL:errorHTMLFileURL]];
    
    // No automatic scroll inset adjustment, but not a problem since the error view displays static centered content
    [self.view insertSubview:errorWebView atIndex:1];
    self.errorWebView = errorWebView;
    
    self.progressView.alpha = 0.f;
    
    self.normalToolbarItems = self.toolbar.items;
    
    // Build the toolbar displayed when the web view is loading content
    NSMutableArray *loadingToolbarItems = [NSMutableArray arrayWithArray:self.normalToolbarItems];
    UIBarButtonItem *stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stop:)];
    [loadingToolbarItems replaceObjectAtIndex:[loadingToolbarItems indexOfObject:self.refreshBarButtonItem] withObject:stopBarButtonItem];
    self.loadingToolbarItems = [NSArray arrayWithArray:loadingToolbarItems];
    
    [self updateTitle];
    [self updateErrorDescription];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateInterfaceAnimated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.webView stopLoading];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Climb up the parent view controller hierarchy to find if modal dismissal is taking place
    BOOL isBeingDismissed = [self isBeingDismissed];
    UIViewController *parentViewController = self.parentViewController;
    while (! isBeingDismissed && parentViewController) {
        isBeingDismissed = [parentViewController isBeingDismissed];
        if (isBeingDismissed) {
            break;
        }
        parentViewController = parentViewController.parentViewController;
    }
    
    if ([self isMovingFromParentViewController] || isBeingDismissed) {
        if (! _isFinished) {
            NSError *error = CPAErrorFromCode(CPAErrorAuthorizationCancelled);
            self.completionBlock ? self.completionBlock(NO, error) : nil;
        }
    }
}

#pragma mark Layout and display

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Position the progress view under the top layout guide when wrapped in a navigation controller
    self.progressView.frame = CGRectMake(CGRectGetMinX(self.progressView.frame),
                                         self.navigationController ? self.topLayoutGuide.length : 0.f,
                                         CGRectGetWidth(self.progressView.frame),
                                         CGRectGetHeight(self.progressView.frame));
    
    // Adjust the toolbar height depending on the screen orientation
    CGSize toolbarSize = [self.toolbar sizeThatFits:self.view.bounds.size];
    self.toolbar.frame = (CGRect){CGPointMake(0.f, CGRectGetHeight(self.view.bounds) - toolbarSize.height), toolbarSize};
    
    // Properly position the vertical scroll bar to avoid the bottom toolbar
    UIScrollView *scrollView = self.webView.scrollView;;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    // Keyboard visible: Adjust content and indicator insets to avoid being hidden by the keyboard
    CPAKeyboardInformation *keyboardInformation = [CPAKeyboardInformation keyboardInformation];
    if (keyboardInformation) {
        CGRect keyboardEndFrameInScrollView = [scrollView convertRect:keyboardInformation.endFrame fromView:nil];
        CGFloat keyboardHeightAdjustment = CGRectGetHeight(scrollView.frame) - CGRectGetMinY(keyboardEndFrameInScrollView) + scrollView.contentOffset.y;
        contentInset.bottom = keyboardHeightAdjustment;
    }
    // Keyboard not visible: Adjust content and indicator insets to avoid being hidden by the toolbar
    else {
        contentInset.bottom = toolbarSize.height;
    }
    
    scrollView.contentInset = contentInset;
    scrollView.scrollIndicatorInsets = contentInset;
}

- (void)updateInterfaceAnimated:(BOOL)animated
{
    self.goBackBarButtonItem.enabled = self.webView.canGoBack;
    self.goForwardBarButtonItem.enabled = self.webView.canGoForward;
    
    if (self.webView.loading) {
        [self.toolbar setItems:self.loadingToolbarItems animated:animated];
    }
    else {
        [self.toolbar setItems:self.normalToolbarItems animated:animated];
    }
    
    [self updateTitle];
}

- (void)updateTitle
{
    if (self.currentURL) {
        [self.webView evaluateJavaScript:@"document.title" completionHandler:^(NSString *title, NSError *error) {
            self.title = title;
        }];
    }
    else {
        self.title = CPALocalizedString(@"Untitled", nil);
    }
}

- (void)updateErrorDescription
{
    if (! self.currentError) {
        return;
    }
    
    NSString *localizedEscapedDescription = [CPALocalizedDescriptionForCFNetworkError(self.currentError.code) stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    if (! localizedEscapedDescription) {
        localizedEscapedDescription = [CPALocalizedDescriptionForCFNetworkError(kCFURLErrorUnknown) stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    }
    NSString *replaceErrorJavaScript = [NSString stringWithFormat:@"document.getElementById('localizedErrorDescription').innerHTML = '%@'", localizedEscapedDescription];
    [self.errorWebView evaluateJavaScript:replaceErrorJavaScript completionHandler:nil];
}

#pragma mark WKWebViewDelegate protocol implementation

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // Implemented so that -webView:didReceiveServerRedirectForProvisionalNavigation: gets called
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    [self processURL:webView.URL];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        return;
    }
    
    if (self.errorWebView.alpha == 1.f) {
        [UIView animateWithDuration:CPAWebViewFadeAnimationDuration animations:^{
            self.errorWebView.alpha = 0.f;
        }];
    }
    
    self.currentError = nil;
    
    [self setProgress:0.f animated:YES];
    
    [self updateInterfaceAnimated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if (webView == self.errorWebView) {
        // Reliably executing JavaScript requires us to wait until the error page has been loaded
        [self updateErrorDescription];
        return;
    }
    
    [UIView animateWithDuration:CPAWebViewFadeAnimationDuration animations:^{
        self.webView.alpha = 1.f;
        self.errorWebView.alpha = 0.f;
    }];
    
    [self setProgress:1.f animated:YES];
    
    self.currentURL = self.webView.URL;
    [self updateInterfaceAnimated:YES];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (webView == self.errorWebView) {
        return;
    }
    
    if (! [error.domain isEqualToString:NSURLErrorDomain] || error.code != NSURLErrorCancelled) {
        [UIView animateWithDuration:CPAWebViewFadeAnimationDuration animations:^{
            self.webView.alpha = 0.f;
            self.errorWebView.alpha = 1.f;
        }];
        
        self.currentError = error;
        [self updateErrorDescription];
    }
    
    [self setProgress:1.f animated:YES];
    
    [self updateInterfaceAnimated:YES];
}

#pragma mark Authentication result

- (void)processURL:(NSURL *)URL
{
    if ([URL.scheme isEqualToString:CPAWebViewCallbackURLScheme]) {
        _isFinished = YES;
        
        NSError *error = CPAErrorFromCallbackURL(URL);
        self.completionBlock ? self.completionBlock(YES, error) : nil;
    }
}

#pragma mark Action callbacks

- (IBAction)goBack:(id)sender
{
    [self.webView goBack];
    [self updateInterfaceAnimated:YES];
}

- (IBAction)goForward:(id)sender
{
    [self.webView goForward];
    [self updateInterfaceAnimated:YES];
}

- (IBAction)refresh:(id)sender
{
    // Reload the currently displayed page (if any)
    if ([self.currentURL absoluteString].length != 0) {
        [self.webView reload];
    }
    // Reload the start page
    else {
        [self.webView loadRequest:self.request];
    }
    [self updateInterfaceAnimated:YES];
}

- (void)stop:(id)sender
{
    [self.webView stopLoading];
    [self updateInterfaceAnimated:YES];
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != s_KVOContext) {
        return;
    }
    
    // Check if loading since progress information can be received before -webView:didStartProvisionalNavigation:, which
    // initially resets progress to 0
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"] && ((WKWebView *)self.webView).loading) {
        [self setProgress:self.webView.estimatedProgress animated:YES];
    }
}

@end

#pragma mark Static functions

static NSURL *CPAFullVerificationURL(NSURL *verificationURL, NSString *userCode)
{
    // To automatically enter the user code, we need to add a user_code and a redirect_uri parameters to the URL. The redirect URI could be
    // used as a way to return to the application if Safari was used to enter credentials. This safe way of supplying credentials sadly leads
    // to App Store rejection nowadays (see http://furbo.org/2014/09/24/in-app-browsers-considered-harmful/, for example), an in-app web
    // browser is therefore used
    NSURLComponents *callbackURLComponents = [[NSURLComponents alloc] init];
    callbackURLComponents.scheme = CPAWebViewCallbackURLScheme;
    callbackURLComponents.host = @"verification";
    NSString *callbackURLString = callbackURLComponents.URL.absoluteString;
    
    // .query automatically adds percent encoding
    NSURLComponents *fullVerificationURLComponents = [NSURLComponents componentsWithURL:verificationURL resolvingAgainstBaseURL:NO];
    fullVerificationURLComponents.query = [NSString stringWithFormat:@"user_code=%@&redirect_uri=%@", userCode, callbackURLString];
    
    return fullVerificationURLComponents.URL;
}

static NSError *CPAErrorFromCallbackURL(NSURL *callbackURL)
{
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:callbackURL resolvingAgainstBaseURL:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == 'result'"];
    NSURLQueryItem *resultQueryItem = [URLComponents.queryItems filteredArrayUsingPredicate:predicate].firstObject;
    NSString *result = resultQueryItem.value;
    return ! [result isEqualToString:@"success"] ? CPAErrorFromIdentifier(result) : nil;
}
