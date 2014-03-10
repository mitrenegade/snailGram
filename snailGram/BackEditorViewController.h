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
    UITextView *textViewEditing;
}

@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (weak, nonatomic) IBOutlet UITextView *textViewTo;
@property (weak, nonatomic) IBOutlet UIView *viewPostcard;

-(IBAction)didClickSave:(id)sender;
@end
