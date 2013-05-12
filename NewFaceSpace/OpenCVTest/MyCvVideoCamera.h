//
//  MyCvVideoCamera.h
//  FaceSpace
//
//  Created by Woodley, Bob on 5/3/13.
//  Copyright (c) 2013 Woodley, Bob. All rights reserved.
//
#import <opencv2/highgui/cap_ios.h>

#import <UIKit/UIKit.h>

@interface MyCvVideoCamera : CvVideoCamera

- (void)updateOrientation;
- (void)layoutPreviewLayer;

@property (nonatomic, retain) CALayer *customPreviewLayer;

@end