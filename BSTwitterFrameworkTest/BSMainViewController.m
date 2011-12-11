//
//  BSMainViewController.m
//  BSTwitterFramework
//
//  Created by Sasmito Adibowo on 09-12-11.
//  Copyright (c) 2011 Basil Salad Software. Some rights reserved – refer to the included LICENSE file.
//  http://basil-salad.com
//

#import "BSMainViewController.h"
#import "Secrets.h"

@implementation BSMainViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(BSFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showInfo:(id)sender
{    
    BSFlipsideViewController *controller = [[BSFlipsideViewController alloc] initWithNibName:@"BSFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:controller animated:YES];
}

#pragma mark Event Handlers

-(IBAction) onAuthenticate:(id) sender 
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* splashPath = [mainBundle pathForResource:@"sample_splash" ofType:@"html"];
    BSWebAuthViewController* ctrl = [BSWebAuthViewController instantiate];
    ctrl.delegate = self;
    ctrl.consumerKey = BSSampleConsumerKey;
    ctrl.consumerSecret = BSSampleConsumerSecret;
    ctrl.callbackURL = [NSURL URLWithString:BSSampleCallbackURL];
    ctrl.splashURL = [NSURL fileURLWithPath:splashPath];    
    [self presentModalViewController:ctrl animated:YES];
    
}

#pragma mark BSWebAuthViewController


-(void) webAuthViewControllerDidCancel:(BSWebAuthViewController*) ctrl 
{
    [ctrl dismissModalViewControllerAnimated:YES];
}


-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didCompleteWithResponseDictionary:(NSDictionary*) responseDictionary;
{
    NSLog(@"Access Token:\t%@",ctrl.accessToken);
    NSLog(@"Access Token secret:\t%@",ctrl.accessTokenSecret);

    [ctrl dismissModalViewControllerAnimated:YES];

}

-(void) webAuthViewController:(BSWebAuthViewController*)ctrl didFailWithError:(NSError*) error
{
    NSLog(@"Error :\t%@",error);
    [ctrl dismissModalViewControllerAnimated:YES];
}



@end
