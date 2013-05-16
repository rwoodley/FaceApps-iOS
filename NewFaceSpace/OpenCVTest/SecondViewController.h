//
//  SecondViewController.h
//  FaceSpace
//
//  Created by Woodley, Bob on 4/25/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
{
    UIImage *_FaceImage;
//    NSMutableData *_responseData;
}

@property (nonatomic, retain) UIImage *FaceImage;

@property (weak, nonatomic) IBOutlet UIImageView *FaceImageView;
- (IBAction)userTappedSubmitFace:(id)sender;
@end
