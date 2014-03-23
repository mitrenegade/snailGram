//
//  ShellViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCard.h"
#import "AWSHelper.h"
#import "GPCameraDelegate.h"

@class GPCamera;
@interface ShellViewController : UIViewController <GPCameraDelegate>
{
    UIImage *selectedImage;
    UIAlertView *alertView;
    GPCamera *camera;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;
@property (weak, nonatomic) IBOutlet UIButton *buttonLibrary;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UILabel *labelInstructions;
- (IBAction)didClickButton:(id)sender;

@end
