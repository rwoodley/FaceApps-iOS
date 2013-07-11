//
//  RollViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 6/23/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "ViewController.h"
//#import "WebViewController.h"
#import "RollViewController.h"

@interface RollViewController ()

@end

@implementation RollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)viewWillDisappear:(BOOL)animated
{
    /*
    int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    ViewController *parent = (ViewController *)[self.navigationController.viewControllers objectAtIndex:currentVCIndex];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"RollViewController was popped");
        [parent startCamera];
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _preventRecursion = false;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_preventRecursion) return;
    _preventRecursion = true;
    // Hack to force this to be in landscape mode:
    // see: http://stackoverflow.com/questions/9826920/uinavigationcontroller-force-rotate
    //set statusbar to the desired rotation position
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    //present/dismiss viewcontroller in order to activate rotating.
    UIViewController *mVC = [[UIViewController alloc] init];
     [self presentViewController:mVC animated:NO completion:NULL];
     [self dismissViewControllerAnimated:NO completion:NULL];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.FaceFieldURL];
    [self.webView loadRequest:request];
    _preventRecursion = false;
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
