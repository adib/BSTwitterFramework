//
//  BSWebAuthViewController.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 10-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BSWebAuthViewControllerDelegate;

@interface BSWebAuthViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,weak) id<BSWebAuthViewControllerDelegate> delegate;

@property (nonatomic,weak) IBOutlet UIWebView* mainWebView;

@property (nonatomic,weak) IBOutlet UIBarButtonItem* rightBarButton;


@property (nonatomic,strong) NSURL* requestTokenURL;
@property (nonatomic,strong) NSURL* authorizeURL;
@property (nonatomic,strong) NSURL* accessTokenURL;
@property (nonatomic,strong) NSURL* callbackURL;

@property (nonatomic,strong) NSURL* splashURL;
@property (nonatomic,strong) NSString* consumerKey;
@property (nonatomic,strong) NSString* consumerSecret;

@property (nonatomic,strong,readonly) NSString* accessToken;
@property (nonatomic,strong,readonly) NSString* accessTokenSecret;

@property (nonatomic,strong,readonly) NSString* requestToken;
@property (nonatomic,strong,readonly) NSString* requestTokenSecret;



/**
 The designated factory method.
 Creates and initializes the view controller.
 */
+(BSWebAuthViewController*) instantiate;

-(IBAction) onRightButton:(id)sender;



@end

//---

@protocol BSWebAuthViewControllerDelegate <NSObject>


-(void) webAuthViewControllerDidCancel:(BSWebAuthViewController*) ctrl;


-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didCompleteWithResponseDictionary:(NSDictionary*) responseDictionary;

-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didFailWithError:(NSError*) error;

@end

//---

extern NSString* const BSWebAuthViewControllerErrorDomain;

enum BSWebAuthViewControllerError {
    BSWebAuthViewControllerErrorNone,
    BSWebAuthViewControllerErrorRequestTokenFailed,
    BSWebAuthViewControllerErrorWebLoginFailed
};
