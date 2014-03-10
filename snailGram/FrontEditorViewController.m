//
//  FrontEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "FrontEditorViewController.h"
#import "AddressEditorViewController.h"

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

    if ([_currentPostCard.message length])
        self.textViewMessage.text = _currentPostCard.message;
    [self.imageView setImage:self.image];

//    [self.imageView.layer setBorderWidth:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickFlip:(id)sender {
    [self performSegueWithIdentifier:@"PushBackEditor" sender:self];
}

#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = _currentPostCard.message;
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = [UIColor darkGrayColor];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (_currentPostCard.message.length == 0) {
        textView.text = MESSAGE_PLACEHOLDER_TEXT;
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
    NSString *oldComments = _currentPostCard.message;
    _currentPostCard.message = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([_currentPostCard.message length] > MESSAGE_LENGTH_LIMIT) {
        _currentPostCard.message = oldComments;
        textView.text = oldComments;
        return NO;
    }

    return YES;
}
@end
