//
//  FrontEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "FrontEditorViewController.h"

#define PLACEHOLDER_TEXT @"Please enter a message"
#define MESSAGE_LENGTH_LIMIT 500

@interface FrontEditorViewController ()

@end

@implementation FrontEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.imageView setImage:self.image];
    message = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = message;
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor darkGrayColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (message.length == 0) {
        textView.text = PLACEHOLDER_TEXT;
        textView.font = [UIFont fontWithName:@"Noteworthy-light" size:15];
        textView.textColor = [UIColor blackColor];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];

        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    NSString *oldComments = message;
    message = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([message length] > MESSAGE_LENGTH_LIMIT) {
        message = oldComments;
        textView.text = oldComments;
        return NO;
    }

    return YES;
}

@end
