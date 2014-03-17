//
//  FrontEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FrontEditorViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL dragging;
    UIView *viewDragging;
    CGPoint initialTouch;
    CGRect initialFrame;
}
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UIView *viewBounds;
@property (strong, nonatomic) UIImageView *imageView; // add programmatically
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (weak, nonatomic) IBOutlet UIView *textCanvas;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) IBOutlet UIButton *buttonText;

// hints
@property (nonatomic, weak) IBOutlet UILabel *labelHint;

-(IBAction)didClickNext:(id)sender;
-(IBAction)didClickButtonText:(id)sender;
-(IBAction)didClickBack:(id)sender;
@end