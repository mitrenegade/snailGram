//
//  FrontEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LightTextDarkBG = 0,
    DarkTextLightBG,
    LightText,
    DarkText,
    TextColorMax
} TextColorState;

@interface FrontEditorViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL dragging;
    UIView *viewDragging;
    CGPoint initialTouch;
    CGRect initialFrame;

    BOOL edited;

    UIAlertView *alertView;
    TextColorState textColorState;
}
@property (weak, nonatomic) IBOutlet UIView *canvas;
@property (weak, nonatomic) IBOutlet UIView *viewBounds;
@property (strong, nonatomic) UIImageView *imageView; // add programmatically
@property (weak, nonatomic) IBOutlet UIView *textCanvas;
@property (weak, nonatomic) IBOutlet UIView *textBG;
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) IBOutlet UIButton *buttonText;
@property (nonatomic, weak) IBOutlet UIButton *buttonTextColor;

// hints
@property (nonatomic, weak) IBOutlet UILabel *labelHintText;
@property (nonatomic, weak) IBOutlet UILabel *labelHintDrag;

-(IBAction)didClickNext:(id)sender;
-(IBAction)didClickButtonText:(id)sender;
-(IBAction)didClickBack:(id)sender;
-(IBAction)didToggleTextColor:(id)sender;
@end