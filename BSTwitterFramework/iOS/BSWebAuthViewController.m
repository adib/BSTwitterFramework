//
//  BSWebAuthViewController.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 10-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import "BSWebAuthViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "OAuthCore.h"
#import "OAuth+Additions.h"
// this is ARC code.
#if !__has_feature(objc_arc)
#error Need automatic reference counting to compile this.
#endif

NSString* const BSWebAuthViewControllerErrorDomain = @"com.basilsalad.BSWebAuthViewControllerErrorDomain";


@interface BSWebAuthViewController()

@property (nonatomic,readonly,strong) UIView* shadeView;
@property (nonatomic,readonly,strong) UIActivityIndicatorView* shadeActivityIndicatorView;

@end


@implementation BSWebAuthViewController {
    BOOL showingShade;
    BOOL kickstart;
}


@synthesize mainWebView;
@synthesize delegate;
@synthesize rightBarButton;
@synthesize requestTokenURL;
@synthesize authorizeURL;
@synthesize accessTokenURL;
@synthesize callbackURL;
@synthesize consumerKey;
@synthesize consumerSecret;
@synthesize accessToken;
@synthesize accessTokenSecret;
@synthesize requestToken;
@synthesize requestTokenSecret;
@synthesize shadeView;
@synthesize shadeActivityIndicatorView;
@synthesize splashURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.requestTokenURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
        self.authorizeURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"];
        self.accessTokenURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
        showingShade = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) showShadeView:(BOOL) show  
{
    if (showingShade == show) {
        return; // already in the correct state
    }
    
    const float shadeTargetAlpha = 0.7f;
    const float animationDuration = 0.3f;
    UIView* shade = self.shadeView;
    if (show) {
        shade.alpha = 0;
        [self.view insertSubview:shade aboveSubview:self.mainWebView];        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        shade.alpha = shadeTargetAlpha;
        [UIView commitAnimations];        
        [self.shadeActivityIndicatorView startAnimating];
    } else {
        [self.shadeActivityIndicatorView stopAnimating];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        shade.alpha = 0;
        [UIView commitAnimations];
        [shade performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:animationDuration];        
    }
    
    showingShade = show;
}

+(BSWebAuthViewController*) instantiate 
{
    BOOL isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    BSWebAuthViewController* ctrl = [[self alloc] initWithNibName: isPad ? @"BSWebAuthViewController_Pad" : @"BSWebAuthViewController_Phone" bundle:nil];
    
    if (isPad) {
        ctrl.modalPresentationStyle = UIModalPresentationFormSheet;
    } 
    return ctrl;    
}


-(void) startHandshake 
{
    requestToken = nil;
    requestTokenSecret = nil;
    
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    NSString* authorizeURLString = [self.authorizeURL absoluteString];
    
    ASIFormDataRequest*  request_ = [ASIFormDataRequest requestWithURL:self.requestTokenURL];
    ASIFormDataRequest __weak* request = request_;
    [request buildPostBody];
    NSString* header = OAuthorizationHeader([request url], [request requestMethod], [request postBody], self.consumerKey, self.consumerSecret, @"", @"");
    [request addRequestHeader:@"Authorization" value:header];
    
    [request setCompletionBlock:^{
        NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithCapacity:3];
        NSString* responseString = request.responseString;
        NSArray* components = [responseString componentsSeparatedByString:@"&"];
        for (NSString* component in components) {
            NSArray* pair = [component componentsSeparatedByString:@"="];
            if (pair.count == 2) {
                [resultDict setObject:[pair objectAtIndex:1] forKey:[pair objectAtIndex:0]];
            }
        }
        
        BOOL callbackConfirmed = [[resultDict objectForKey:@"oauth_callback_confirmed"] boolValue];
        NSString* token = [resultDict objectForKey:@"oauth_token"];
        NSString* tokenSecret = [resultDict objectForKey:@"oauth_token_secret"];

        if (callbackConfirmed) {
            NSString* requestString = [NSString stringWithFormat:@"%@?oauth_token=%@",authorizeURLString,token];
            NSURL* requestURL = [NSURL URLWithString:requestString];
            [mainQueue addOperationWithBlock:^{
                requestToken = token;
                requestTokenSecret = tokenSecret;

                NSURLRequest* authorizeRequest = [NSURLRequest requestWithURL:requestURL];  
                [self.mainWebView loadRequest:authorizeRequest];
            }];
        } else {
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
            [userInfo setObject:NSLocalizedString(@"Token request failed", @"BSWebAuthViewController") forKey:NSLocalizedDescriptionKey];
            [userInfo setObject:[request url] forKey:NSURLErrorKey];
            NSError* error = [NSError errorWithDomain:BSWebAuthViewControllerErrorDomain code:BSWebAuthViewControllerErrorRequestTokenFailed userInfo:userInfo];
            
            [mainQueue addOperationWithBlock:^{
                [self.delegate webAuthViewController:self didFailWithError:error];
            }];
        }
    }];
    
    [request setFailedBlock:^{
        NSError* error = request.error;
        [mainQueue addOperationWithBlock:^{
            [self.delegate webAuthViewController:self didFailWithError:error];
        }];
    }];
    
    [self showShadeView:YES];    
    [request startAsynchronous];
}

-(void) completeHandshakeWithVerifier:(NSString*) verifier
{
    
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    
    NSString* accessTokenURLString = [self.accessTokenURL absoluteString];
    NSURL* requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?oauth_verifier=%@",accessTokenURLString,verifier]];
    ASIFormDataRequest*  request_ = [ASIFormDataRequest requestWithURL:requestURL];
    ASIFormDataRequest __weak* request = request_;
    [request buildPostBody];
    NSString* header = OAuthorizationHeader([request url], [request requestMethod], [request postBody], self.consumerKey, self.consumerSecret, requestToken, requestTokenSecret);
    [request addRequestHeader:@"Authorization" value:header];

    [request setCompletionBlock:^{
        NSString* responseString = request.responseString;
        NSDictionary* parameterDict = [NSURL ab_parseURLQueryString:responseString];

        NSString* token = [parameterDict objectForKey:@"oauth_token"];
        NSString* tokenSecret = [parameterDict objectForKey:@"oauth_token_secret"];        
        [mainQueue addOperationWithBlock:^{
            accessToken = token;
            accessTokenSecret = tokenSecret;
            [self.delegate webAuthViewController:self didCompleteWithResponseDictionary:parameterDict];
            [self showShadeView:NO];
        }];
    }];
    [request setFailedBlock:^{
        NSError* error = request.error;
        [mainQueue addOperationWithBlock:^{
            [self showShadeView:NO];
            [self.delegate webAuthViewController:self didFailWithError:error];
        }];
    }];
    
    [self showShadeView:YES];
    [request startAsynchronous];
}

#pragma mark - View lifecycle




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (splashURL) {
        kickstart = YES;
        NSURLRequest* request = [NSURLRequest requestWithURL:splashURL];
        [self.mainWebView loadRequest:request];
    }  else {
        [self performSelectorOnMainThread:@selector(startHandshake) withObject:nil waitUntilDone:NO];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mainWebView = nil;
    self.rightBarButton = nil;
    
    [shadeActivityIndicatorView removeFromSuperview];
    shadeActivityIndicatorView = nil;
    [shadeView removeFromSuperview];
    shadeView = nil;
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark Command Handlers

-(IBAction) onRightButton:(id)sender 
{
    [self.delegate webAuthViewControllerDidCancel:self];
}

#pragma mark Property Access

-(UIActivityIndicatorView *)shadeActivityIndicatorView {
    if (!shadeActivityIndicatorView) {
        shadeActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return shadeActivityIndicatorView;
}

-(UIView *)shadeView {
    if (!shadeView) {
        CGRect webFrame = self.mainWebView.frame;
        shadeView = [[UIView alloc] initWithFrame:webFrame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.opaque = NO;
        
        UIActivityIndicatorView* acView = self.shadeActivityIndicatorView;
        CGRect acViewFrame = acView.frame;
        
        acViewFrame.origin.x = (webFrame.size.width - acViewFrame.size.width) / 2;
        acViewFrame.origin.y = (webFrame.size.height - acViewFrame.size.height) / 2;
        acView.frame = acViewFrame;
        [shadeView addSubview:acView];
    }
    return shadeView;
}

#pragma mark UIWebViewDelegate 

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView == self.mainWebView) {
        NSURL* requestURL = request.URL;
        if ([callbackURL.host compare:requestURL.host options:NSCaseInsensitiveSearch] == NSOrderedSame
            && [callbackURL.path compare:requestURL.path options:NSCaseInsensitiveSearch] == NSOrderedSame            
            && [callbackURL.scheme compare:requestURL.scheme options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            // we are in callback
            NSDictionary* parameterDict = [NSURL ab_parseURLQueryString:requestURL.query];
            NSString* token = [parameterDict objectForKey:@"oauth_token"];
            if ([requestToken isEqualToString:token]) {
                NSString* verifier = [parameterDict objectForKey:@"oauth_verifier"];
                [self completeHandshakeWithVerifier:verifier];                
            } else {
                // error
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
                [userInfo setObject:NSLocalizedString(@"Web login failed", @"BSWebAuthViewController") forKey:NSLocalizedDescriptionKey];
                [userInfo setObject:requestURL forKey:NSURLErrorKey];
                NSError* error = [NSError errorWithDomain:BSWebAuthViewControllerErrorDomain code:BSWebAuthViewControllerErrorWebLoginFailed userInfo:userInfo];
                
                [self.delegate webAuthViewController:self didFailWithError:error];
            }
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (webView == self.mainWebView) {
        if (!kickstart) {
            [self showShadeView:YES];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    if (webView == self.mainWebView) {
        if (!kickstart) {
            [self showShadeView:NO];
        } else {
            // starting handshake here.
            kickstart = NO;
            [self performSelectorOnMainThread:@selector(startHandshake) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView == self.mainWebView) {
        if (!kickstart) {
            [self showShadeView:NO];
        }
        [self.delegate webAuthViewController:self didFailWithError:error];
    }    
}

@end
