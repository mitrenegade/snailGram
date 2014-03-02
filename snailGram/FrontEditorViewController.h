//
//  FrontEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrontEditorViewController : UIViewController <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (nonatomic, strong) UIImage *image;

-(IBAction)didClickFlip:(id)sender;

@end