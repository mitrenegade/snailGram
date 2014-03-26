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
#import "PostCard+Parse.h"
#import "UIAlertView+MKBlockAdditions.h"

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

    self.imageView = [[UIImageView alloc] init];
    [self.viewBounds addSubview:self.imageView];
    [self.imageView setImage:self.image];
    float targetWidth = self.viewBounds.frame.size.width;
    float scale = targetWidth / self.image.size.width;
    CGRect frame = CGRectMake(0, -((self.image.size.height * scale)/2 - self.viewBounds.frame.size.height/2) + IMAGE_BORDER, self.image.size.width * scale, self.image.size.height * scale);
    [self.imageView setFrame:frame];

    [self.canvas.layer setBorderWidth:2];

    NSLog(@"Initial image size: %f %f", self.image.size.width, self.image.size.height);

    // gestures
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.canvas addGestureRecognizer:pan];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];

    [self.textCanvas setHidden:YES];
    [self.labelHintText setAlpha:0];
    [self.labelHintDrag setAlpha:0];
    [self.labelHintText setFont:FONT_ITALIC(12)];
    [self.labelHintDrag setFont:FONT_ITALIC(12)];

    [self.viewBounds setClipsToBounds:YES];

    [self performSelector:@selector(showHintDrag) withObject:nil afterDelay:3];

    edited = YES;
    [self.buttonTextColor setHidden:YES];
    textColorState = LightText;
    [self updateTextColors];

    [self.textCanvas setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickNext:(id)sender {
    if (edited) {
        [self saveScreenshot];
    }

    [self performSegueWithIdentifier:@"PushBackEditor" sender:self];
}

-(IBAction)didClickButtonText:(id)sender {
    edited = YES;
    [self.textCanvas setHidden:!self.textCanvas.hidden];
    if (self.textCanvas.hidden == NO) {
        [self performSelector:@selector(beginEdit) withObject:nil afterDelay:2];
        [self.buttonText setTitle:@"Remove text" forState:UIControlStateNormal];
        [self.buttonTextColor setHidden:NO];
        [self showHintText];
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self.buttonText setTitle:@"Add text" forState:UIControlStateNormal];
        [self.buttonTextColor setHidden:YES];
        [self hideHintText];
    }
}

-(IBAction)didToggleTextColor:(id)sender {
    textColorState += 1;
    if (textColorState == TextColorMax)
        textColorState = 0;

    [self updateTextColors];
}

-(void)updateTextColors {
    if (textColorState == LightTextDarkBG) {
        self.textBG.backgroundColor = [UIColor blackColor];
        self.textViewMessage.textColor = [UIColor whiteColor];
        [self.textViewMessage setFont:FONT_REGULAR(15)];
    }
    else if (textColorState == DarkTextLightBG) {
        self.textBG.backgroundColor = [UIColor whiteColor];
        self.textViewMessage.textColor = [UIColor blackColor];
        [self.textViewMessage setFont:FONT_REGULAR(15)];
    }
    else if (textColorState == LightText) {
        self.textBG.backgroundColor = [UIColor clearColor];
        self.textViewMessage.textColor = [UIColor whiteColor];
        [self.textViewMessage setFont:FONT_BOLD(15)];
    }
    else if (textColorState == DarkText) {
        self.textBG.backgroundColor = [UIColor clearColor];
        self.textViewMessage.textColor = [UIColor blackColor];
        [self.textViewMessage setFont:FONT_BOLD(15)];
    }
}

-(void)didClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)beginEdit {
    if (!dragging) {
        [self.textViewMessage becomeFirstResponder];
    }
}

-(void)saveScreenshot {
    //alertView = [UIAlertView alertViewWithTitle:@"Uploading image..." message:nil];
    // Create the screenshot
    float scale = 5;

    if ([_currentPostCard.text length] == 0)
        [self.textCanvas setHidden:YES];

    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
    CGSize size = CGSizeMake(self.canvas.frame.size.width * scale, self.canvas.frame.size.height * scale);
    UIGraphicsBeginImageContext(size);
    // Put everything in the current view into the screenshot
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, t);
    [self.canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextRestoreGState(ctx);
    // Save the current image context info into a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self uploadImage:newImage];
}

#pragma mark AWS
-(void)uploadImage:(UIImage *)image {
    NSString *name = [NSString stringWithFormat:@"%@-f", _currentPostCard.parseID];
    [AWSHelper uploadImage:image withName:name toBucket:AWS_BUCKET withCallback:^(NSString *url) {
        // todo: must handle internet connectivity errors
        // update postcard with the url
        _currentPostCard.image_url = [AWSHelper urlForPhotoWithKey:name];
        _currentPostCard.front_loaded = @YES;
        [_currentPostCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
            if (success) {
                edited = NO;
            }
            else {
                [UIAlertView alertViewWithTitle:@"Could not save image" message:@"We couldn't save your image. Please try again." cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Retry"] onDismiss:^(int buttonIndex) {
                    [self uploadImage:image];
                } onCancel:nil];
            }
        }];
    }];
}
#pragma mark TextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView {
    textView.text = _currentPostCard.text;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    textView.contentSize = textView.frame.size; // on phone, contentSize gets changed so textView becomes scrollable.
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

    edited = YES;

    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    CGPoint center = self.textCanvas.center;
    CGSize size = [textView.text sizeWithFont:textView.font constrainedToSize:CGSizeMake(self.canvas.frame.size.width - 2*IMAGE_BORDER, 35)];
    CGRect frame = self.textCanvas.frame;
    frame.size.width = MIN(self.canvas.frame.size.width - 2*IMAGE_BORDER, size.width+2*IMAGE_BORDER);
    self.textCanvas.frame = frame;
    self.textCanvas.center = center;
    if (self.textCanvas.frame.origin.x < IMAGE_BORDER)
        self.textCanvas.frame = CGRectMake(IMAGE_BORDER, self.textCanvas.frame.origin.y, self.textCanvas.frame.size.width, self.textCanvas.frame.size.height);
    if (self.textCanvas.frame.origin.x + self.textCanvas.frame.size.width >= self.canvas.frame.size.width - IMAGE_BORDER)
        self.textCanvas.frame = CGRectMake(310 - self.textCanvas.frame.size.width, self.textCanvas.frame.origin.y, self.textCanvas.frame.size.width, self.textCanvas.frame.size.height);;
}

#pragma mark Gesture recognizers
-(void)handlePan:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!dragging) {
                [self.textViewMessage resignFirstResponder];
                [self hideOrCancelHintDrag];
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
                    // change both x and y position
                    CGPoint point = [gesture locationInView:self.canvas];
                    int dx = point.x - initialTouch.x;
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.x += dx;
                    frame.origin.y += dy;
                    if (frame.origin.x <= IMAGE_BORDER)
                        frame.origin.x = IMAGE_BORDER;
                    if (frame.origin.x >= self.canvas.frame.size.width - self.textCanvas.frame.size.width - IMAGE_BORDER)
                        frame.origin.x = self.canvas.frame.size.width - self.textCanvas.frame.size.width - IMAGE_BORDER;
                    if (frame.origin.y <= IMAGE_BORDER)
                        frame.origin.y = IMAGE_BORDER;
                    if (frame.origin.y >= self.canvas.frame.size.height - self.textCanvas.frame.size.height - IMAGE_BORDER)
                        frame.origin.y = self.canvas.frame.size.height - self.textCanvas.frame.size.height - IMAGE_BORDER;
                    viewDragging.frame = frame;
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
                edited = YES;
            }
        }
    }
}

-(void)handlePinch:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gesture;
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            [self.textViewMessage resignFirstResponder];
            [self hideOrCancelHintDrag];
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
            edited = YES;
        }
    }
}

#pragma mark hint
-(void)showHintDrag {
    if (self.labelHintText.alpha == 1)
        [self hideHintText];
    [UIView animateWithDuration:.5 animations:^{
        [self.labelHintDrag setAlpha:1];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideOrCancelHintDrag) withObject:nil afterDelay:5];
    }];
}

-(void)hideOrCancelHintDrag {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHintDrag) object:nil];
    [UIView animateWithDuration:.5 animations:^{
        [self.labelHintDrag setAlpha:0];
    }];
}

-(void)showHintText {
    if (self.labelHintDrag.alpha == 1)
        [self hideOrCancelHintDrag];
    [UIView animateWithDuration:.5 animations:^{
        [self.labelHintText setAlpha:1];
    }];
}

-(void)hideHintText {
    [UIView animateWithDuration:.5 animations:^{
        [self.labelHintText setAlpha:0];
    }];
}
@end
