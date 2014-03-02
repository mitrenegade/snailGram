//
//  ShellViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCard.h"

@interface ShellViewController : UIViewController
{
    UIImage *selectedImage;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonCamera;
@property (weak, nonatomic) IBOutlet UIButton *buttonLibrary;

@property (nonatomic, strong) PostCard *postCard;
- (IBAction)didClickButton:(id)sender;

@end
