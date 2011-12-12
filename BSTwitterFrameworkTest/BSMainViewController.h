//
//  BSMainViewController.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import "BSFlipsideViewController.h"
#import "BSWebAuthViewController.h"

@class BSTwitterAccessKey;

@interface BSMainViewController : UIViewController <BSFlipsideViewControllerDelegate,BSWebAuthViewControllerDelegate>

-(IBAction)showInfo:(id)sender;

-(IBAction) onAuthenticate:(id) sender;

-(IBAction) onVerifyCredentials:(id)sender;

-(IBAction) onShowDirectMessage:(id)sender;

-(IBAction) onTweet:(id)sender;

@property (nonatomic,strong) BSTwitterAccessKey* twitterAccessKey;

@end
