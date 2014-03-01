//
//  BackEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "BackEditorViewController.h"

#define PLACEHOLDER_TEXT_FROM @"From:"
#define PLACEHOLDER_TEXT_TO @"To:"
#define ADDRESS_LIMIT 300
@interface BackEditorViewController ()

@end

@implementation BackEditorViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickSave:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.textViewFrom)
        textView.text = self.textFrom;
    else if (textView == self.textViewTo)
        textView.text = self.textTo;
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor darkGrayColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    NSString *message;
    NSString *placeholder;
    if (textView == self.textViewFrom) {
        message = self.textFrom;
        placeholder = PLACEHOLDER_TEXT_FROM;
    }
    else if (textView == self.textViewTo) {
        message = self.textTo;
        placeholder = PLACEHOLDER_TEXT_TO;
    }

    if (message.length == 0) {
        textView.text = placeholder;
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
    NSString *oldComments;
    if (textView == self.textViewFrom) {
        oldComments = self.textFrom;
        self.textFrom = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if ([self.textFrom length] > ADDRESS_LIMIT) {
            self.textFrom = oldComments;
            textView.text = oldComments;
            return NO;
        }
    }
    else if (textView == self.textViewTo) {
        oldComments = self.textTo;
        self.textTo = [textView.text stringByReplacingCharactersInRange:range withString:text];
        if ([self.textTo length] > ADDRESS_LIMIT) {
            self.textTo = oldComments;
            textView.text = oldComments;
            return NO;
        }
    }

    return YES;
}
@end
