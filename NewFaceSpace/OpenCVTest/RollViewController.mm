//
//  RollViewController.m
//  FaceSpace
//
//  Created by Woodley, Bob on 6/23/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import "ViewController.h"
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
- (void)viewWillDisappear:(BOOL)animated
{
    int currentVCIndex = [self.navigationController.viewControllers indexOfObject:self.navigationController.topViewController];
    ViewController *parent = (ViewController *)[self.navigationController.viewControllers objectAtIndex:currentVCIndex];
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        NSLog(@"RollViewController was popped");
        [parent startCamera];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
