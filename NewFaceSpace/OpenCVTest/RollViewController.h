//
//  RollViewController.h
//  FaceSpace
//
//  Created by Woodley, Bob on 6/23/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RollViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
