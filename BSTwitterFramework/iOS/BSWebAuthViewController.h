//
//  BSWebAuthViewController.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 10-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//  

#import <UIKit/UIKit.h>


@protocol BSWebAuthViewControllerDelegate;


/**
 A view controller to do OAuth handshake in an embedded browser.
 
 This view controller requires two nibs for iPad and iPhone:
 
  - BSWebAuthViewController_Pad – Used for the iPad
  - BSWebAuthViewController_Phone – Used for the iPhone and iPod touch.

 If you are customizing those nibs, be sure that you have at least a UIWebView that is assigned to #mainWebView and this controller is set as the web view's delegate. 
 
 Follow these steps to use this view controller:
  -# Call #instantiate and get a new instace of the view controller.
  -# Assign #delegate to receive events from the controller.
  -# Present the controller modally.
  -# Dismiss the controller if it reports failure or returns success.
 
 @author Sasmito Adibowo
 */
@interface BSWebAuthViewController : UIViewController<UIWebViewDelegate>

/**
 Delegate that will handle OAuth completion or failure.
 */
@property (nonatomic,weak) id<BSWebAuthViewControllerDelegate> delegate;


/**
 The web view to for the user to login to the OAuth provider.
 */
@property (nonatomic,weak) IBOutlet UIWebView* mainWebView;

/**
 The Cancel button to dismiss this view controller.
 */
@property (nonatomic,weak) IBOutlet UIBarButtonItem* cancelBarButton;


/**
 OAuth "Request Token" URL. Defaults to Twitter's request token URL.
 */
@property (nonatomic,strong) NSURL* requestTokenURL;

/**
 OAuth "Authorize Token" URL. Defaults to Twitter's authorize token URL.
 */
@property (nonatomic,strong) NSURL* authorizeURL;

/**
 OAuth "Access Token" URL. Default's to Twitter's Access
 */
@property (nonatomic,strong) NSURL* accessTokenURL;

/**
 The destination URL that the OAuth provider will redirect the user. 
 You will need to assign this before presenting the URL.
 */
@property (nonatomic,strong) NSURL* callbackURL;

/**
 The URL to show before the OAuth handshake starts. 
 Useful for providing the user with something to see initially. 
 Typically this should point to a local HTML file in the app bundle.
 */
@property (nonatomic,strong) NSURL* splashURL;

/**
 The consumer key to sign OAuth requests.
 You will need to initialize this prior to showing the view controller.
 */
@property (nonatomic,strong) NSString* consumerKey;

/**
 The consumer secret to sign OAuth requests.
 You will need to initialize this prior to showing the view controller.
 */
@property (nonatomic,strong) NSString* consumerSecret;

/**
 The OAuth request token obtained during the handshake.
 Usually you won't need to use this, but it's available in case you need it.
 */
@property (nonatomic,strong,readonly) NSString* requestToken;


/**
 The OAuth request token secret obtained during the handshake.
 Usually you won't need to use this, but it's available in case you need it.
 */
@property (nonatomic,strong,readonly) NSString* requestTokenSecret;

/**
 The OAuth access token obtained when the handshake have completed successfully.
 */
@property (nonatomic,strong,readonly) NSString* accessToken;

/**
 The OAuth access token secret obtained when the handshake have completed successfully.
 */
@property (nonatomic,strong,readonly) NSString* accessTokenSecret;



/**
 The designated factory method.
 Creates and initializes the view controller.
 */
+(BSWebAuthViewController*) instantiate;


/**
 Handles the Cancel button.
 */
-(IBAction) onCancelButton:(id)sender;

@end

//------

/**
 Receives success or cancel events by the view controller.
 @author Sasmito Adibowo
 */
@protocol BSWebAuthViewControllerDelegate <NSObject>


/**
 Signals that the user decides to prematurely cancel the handshake.
 You should dismiss the view controller when this happens.
 
 @param ctrl The sending view controller.
 */
-(void) webAuthViewControllerDidCancel:(BSWebAuthViewController*) ctrl;

/**
 Signifies that the handshake was successful. At this point, you should retrieve  
 ctrl#accessToken and ctrl#accessTokenSecret values as they should already contain the
 correct OAuth token values. Any additional information given by the OAuth provider will be
 in responseDictionary.
 
 Before returning you should dismiss the view controller.
 
 @param ctrl The sending view controller.
 @param responseDictionary Any additional data returned by the OAuth provider.
 */
-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didCompleteWithResponseDictionary:(NSDictionary*) responseDictionary;


/**
 Reports that there was an error during the handshake.
 
 @param ctrl The sending view controller.
 @param error Describes the error that occurred.
 */
-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didFailWithError:(NSError*) error;

@end

//---

/**
 Domain for NSError objects created by this view controller.
 @author Sasmito Adibowo
 */
extern NSString* const BSWebAuthViewControllerErrorDomain;

/**
 Error code values for BSWebAuthViewControllerErrorDomain
 @author Sasmito Adibowo
 */
enum BSWebAuthViewControllerError {
    BSWebAuthViewControllerErrorNone,
    BSWebAuthViewControllerErrorRequestTokenFailed,
    BSWebAuthViewControllerErrorWebLoginFailed
};
