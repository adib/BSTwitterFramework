//
//  BSFlipsideViewController.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import <UIKit/UIKit.h>

@class BSFlipsideViewController;

@protocol BSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BSFlipsideViewController *)controller;
@end

@interface BSFlipsideViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <BSFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
