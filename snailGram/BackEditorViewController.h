//
//  BackEditorViewController.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BackEditorViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textViewFrom;
@property (weak, nonatomic) IBOutlet UITextView *textViewTo;

@property (nonatomic, strong) NSString *textFrom;
@property (nonatomic, strong) NSString *textTo;

-(IBAction)didClickSave:(id)sender;
@end
