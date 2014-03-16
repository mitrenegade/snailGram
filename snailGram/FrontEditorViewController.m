//
//  FrontEditorViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#define IMAGE_BORDER 10

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

    if ([_currentPostCard.text length])
        self.textViewMessage.text = _currentPostCard.text;
    [self.imageView setImage:self.image];

    [self.canvas.layer setBorderWidth:2];

    // gestures
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.canvas addGestureRecognizer:pan];

    [self.textCanvas setHidden:YES];
    [self.labelHint setHidden:YES];

    _currentPostCard.textPosY = @(self.textCanvas.frame.origin.y);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickNext:(id)sender {
    [self performSegueWithIdentifier:@"PushBackEditor" sender:self];
}

-(IBAction)didClickButtonText:(id)sender {
    [self.textCanvas setHidden:!self.textCanvas.hidden];
    if (self.textCanvas.hidden == NO) {
        [self performSelector:@selector(beginEdit) withObject:nil afterDelay:2];
        [self.buttonText setTitle:@"Remove text" forState:UIControlStateNormal];
        [self.labelHint setHidden:NO];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.buttonText setTitle:@"Add text" forState:UIControlStateNormal];
        [self.labelHint setHidden:YES];
    }
}

-(void)beginEdit {
    if (!dragging) {
        [self.textViewMessage becomeFirstResponder];
    }
}

#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = _currentPostCard.text;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    if (_currentPostCard.text.length == 0) {
        textView.text = MESSAGE_PLACEHOLDER_TEXT;
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    if ([text isEqualToString:@"\n"]) {
        // Be sure to test for equality using the "isEqualToString" message
        [textView resignFirstResponder];

        // Return FALSE so that the final '\n' character doesn't get added
        return NO;
    }
    NSString *oldComments = _currentPostCard.text;
    _currentPostCard.text = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if ([_currentPostCard.text length] > MESSAGE_LENGTH_LIMIT) {
        _currentPostCard.text = oldComments;
        textView.text = oldComments;
        return NO;
    }

    return YES;
}

#pragma mark Gesture recognizers
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.canvas];
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!dragging) {
                dragging = YES;
                initialTouch = point;
                if (CGRectContainsPoint(self.textCanvas.frame, point)) {
                    viewDragging = self.textCanvas;
                    initialFrame = viewDragging.frame;

                    [self.textViewMessage resignFirstResponder];
                }
                else if (CGRectContainsPoint(self.imageView.frame, point)) {
                    viewDragging = self.imageView;
                    initialFrame = viewDragging.frame;
                }
                else {
                    dragging = NO;
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            if (dragging) {
                // update frame of viewDragging
                if (viewDragging == self.textCanvas) {
                    // only change Y position
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.y += dy;
                    if (frame.origin.y >= IMAGE_BORDER && frame.origin.y <= self.canvas.frame.size.height - self.textCanvas.frame.size.height - IMAGE_BORDER) {
                        viewDragging.frame = frame;

                        _currentPostCard.textPosY = @(self.textCanvas.frame.origin.y);
                    }
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            if (dragging) {
                dragging = NO;
                viewDragging = nil;
            }
        }
    }
}
@end
