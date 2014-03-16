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

    NSLog(@"Initial image size: %f %f", self.image.size.width, self.image.size.height);

    // gestures
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.canvas addGestureRecognizer:pan];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];

    [self.textCanvas setHidden:YES];
    [self.labelHint setHidden:YES];

    [self.viewBounds setClipsToBounds:YES];

    _currentPostCard.textPosY = @(self.textCanvas.frame.origin.y);
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRect frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    [self.imageView setFrame:frame];
    self.imageView.center = CGPointMake(self.viewBounds.frame.size.width/2, self.viewBounds.frame.size.height);

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
-(void)handlePan:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!dragging) {
                dragging = YES;
                CGPoint point = [gesture locationInView:self.canvas];
                initialTouch = point;
                if (CGRectContainsPoint(self.textCanvas.frame, point)) {
                    viewDragging = self.textCanvas;
                    initialFrame = viewDragging.frame;

                    [self.textViewMessage resignFirstResponder];
                }
                else if (CGRectContainsPoint(self.viewBounds.frame, point)) {
                    point = [gesture locationInView:self.viewBounds];
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
                    CGPoint point = [gesture locationInView:self.canvas];
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.y += dy;
                    if (frame.origin.y >= IMAGE_BORDER && frame.origin.y <= self.canvas.frame.size.height - self.textCanvas.frame.size.height - IMAGE_BORDER) {
                        viewDragging.frame = frame;

                        _currentPostCard.textPosY = @(self.textCanvas.frame.origin.y);
                    }
                }
                else if (viewDragging == self.imageView) {
                    CGPoint point = [gesture locationInView:self.viewBounds];
                    // change x and y
                    int dx = point.x - initialTouch.x;
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.y += dy;
                    frame.origin.x += dx;
                    NSLog(@"New frame: %f %f %f %f imageSize %f %f", frame.origin.x, frame.origin.y, frame.origin.x + frame.size.width, frame.origin.y + frame.size.height, self.image.size.width, self.image.size.height);
                    if (frame.origin.x > 0)
                        frame.origin.x = 0;
                    if (frame.origin.x + frame.size.width < self.viewBounds.frame.size.width)
                        frame.origin.x = self.viewBounds.frame.size.width - frame.size.width;
                    if (frame.origin.y > 0)
                        frame.origin.y = 0;
                    if (frame.origin.y + frame.size.height < self.viewBounds.frame.size.height)
                        frame.origin.y = self.viewBounds.frame.size.height - frame.size.height;
                    viewDragging.frame = frame;
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

-(void)handlePinch:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gesture;
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            initialFrame = self.imageView.frame;
            NSLog(@"Initial: %f %f %f %f", initialFrame.origin.x, initialFrame.origin.y, initialFrame.size.width, initialFrame.size.height);
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            float scale = pinch.scale;
            NSLog(@"Scale: %f", scale);
            CGRect frame;
            frame.size.width = initialFrame.size.width * scale;
            frame.size.height = initialFrame.size.height * scale;
            frame.origin.x = initialFrame.origin.x + initialFrame.size.width / 2 - frame.size.width / 2;
            frame.origin.y = initialFrame.origin.y + initialFrame.size.height / 2 - frame.size.height / 2;

            self.imageView.frame = frame;
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            CGRect frame = self.imageView.frame;
            if (frame.origin.x > 0)
                frame.origin.x = 0;
            if (frame.origin.y > 0)
                frame.origin.y = 0;
            if (frame.size.width < self.viewBounds.frame.size.width) {
                frame.size.width = self.viewBounds.frame.size.width;
                frame.size.height = frame.size.width / self.image.size.width * self.image.size.height;
            }
            if (frame.size.height < self.viewBounds.frame.size.height)
                frame.size.height = self.viewBounds.frame.size.height;
            if (frame.origin.x + frame.size.width < self.viewBounds.frame.size.width)
                frame.origin.x = self.viewBounds.frame.size.width - frame.size.width;
            if (frame.origin.y + frame.size.height < self.viewBounds.frame.size.height)
                frame.origin.y = self.viewBounds.frame.size.height - frame.size.height;
            self.imageView.frame = frame;
        }
    }
}
@end
