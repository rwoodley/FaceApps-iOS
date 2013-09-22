//
//  SecondViewController.h
//  FaceSpace
//
//  Created by Woodley, Bob on 4/25/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController <UIAlertViewDelegate>
{
    UIImage *_FaceImage;
//    NSMutableData *_responseData;
    int _userAcceptedTerms;
}

@property (nonatomic, retain) UIImage *FaceImage;
@property (nonatomic, retain) UIImage *FaceImage_Histogram;
@property (weak, nonatomic) IBOutlet UIImageView *FaceImageView;
//- (IBAction)userTappedSubmitFace:(id)sender;
- (IBAction)ComputeAntiFaceButton:(id)sender;

@end
