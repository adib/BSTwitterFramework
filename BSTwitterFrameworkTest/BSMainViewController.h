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

@interface BSMainViewController : UIViewController <BSFlipsideViewControllerDelegate,BSWebAuthViewControllerDelegate>

- (IBAction)showInfo:(id)sender;

-(IBAction) onAuthenticate:(id) sender;

@end
