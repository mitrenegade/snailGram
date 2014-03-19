//
//  BackEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressEditorViewController.h"

@interface BackEditorViewController : UIViewController <UITextViewDelegate, AddressEditorDelegate>
{
    UIAlertView *alertView;
}

@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (weak, nonatomic) IBOutlet UILabel *labelTo;
@property (weak, nonatomic) IBOutlet UIView *canvas;

-(IBAction)didClickSave:(id)sender;
-(IBAction)didClickFront:(id)sender;
@end
