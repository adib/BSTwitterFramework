//
//  BSAppDelegate.h
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSMainViewController;

@interface BSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BSMainViewController *mainViewController;

@end
