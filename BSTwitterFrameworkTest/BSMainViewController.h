//
//  BSMainViewController.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import "BSFlipsideViewController.h"
#import "BSWebAuthViewController.h"

@interface BSMainViewController : UIViewController <BSFlipsideViewControllerDelegate,BSWebAuthViewControllerDelegate>

- (IBAction)showInfo:(id)sender;

-(IBAction) onAuthenticate:(id) sender;

@end
