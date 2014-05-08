//
//  AVCam2ndViewController.m
//  AVCam
//
//  Created by Robert Woodley on 5/1/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "AVCam2ndViewController.h"

@interface AVCam2ndViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;

@end

@implementation AVCam2ndViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.faceImageView.image = self.FaceImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
