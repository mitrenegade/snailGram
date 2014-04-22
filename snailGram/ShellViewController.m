//
//  ShellViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "ShellViewController.h"
#import "FrontEditorViewController.h"
#import "UIAlertView+MKBlockAdditions.h"
#import "PostCard+Parse.h"
#import <QuartzCore/QuartzCore.h>
#import "GPCamera.h"

@interface ShellViewController ()

@end

@implementation ShellViewController

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
    // Do any additional setup after loading the view from its nib.

    [self.imageView setClipsToBounds:YES];

    [self.labelInstructions setFont:FONT_ITALIC(17)];

    [self.buttonLoad setHidden:YES];
#if CAN_LOAD_POSTCARD
    NSArray *postcards = [[PostCard where:@{}] all];
    if ([postcards count])
        [self.buttonLoad setHidden:NO];
#endif
    
    [self.buttonCamera.titleLabel setFont:FONT_REGULAR(18)];
    [self.buttonLibrary.titleLabel setFont:FONT_REGULAR(18)];
    [self.buttonLoad.titleLabel setFont:FONT_REGULAR(18)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickButton:(id)sender {
    if (!camera) {
        camera = [[GPCamera alloc] init];
        [camera setDelegate:self];
    }

    UIButton *button = (UIButton *)sender;
    if (button == self.buttonCamera) {
        [camera startCameraFrom:self];
        [camera addOverlayWithFrame:_appDelegate.window.bounds];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    else if (button == self.buttonLibrary) {
        UIImagePickerController *library = [[UIImagePickerController alloc] init];
        library.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        library.toolbarHidden = YES; // hide toolbar of app, if there is one.
        library.delegate = camera;

        [self presentViewController:library animated:YES completion:nil];
    }
#if CAN_LOAD_POSTCARD
    // todo: add load functionality. That means we will have to store all elements of the postcard and allow the user to edit them as well.
    else if (button == self.buttonLoad) {
        [_appDelegate loadPostcardWithCompletion:^(BOOL success) {
            if (!success) {
                [UIAlertView alertViewWithTitle:@"Could not load postcard" message:@"The saved postcard could not be loaded. Please create a new one."];
            }
            else {
                [self imageSaved];
                selectedImage = nil;
            }
        }];
    }
#endif
}

-(void)imageSaved {
    if (alertView)
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self performSegueWithIdentifier:@"PushFrontEditor" sender:nil];
}

#pragma mark Segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushFrontEditor"]) {
        FrontEditorViewController *controller = [segue destinationViewController];
        controller.image = selectedImage;
    }
}

#pragma mark Camera Delegate
-(void)dismissCamera {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSelectPhoto:(UIImage *)photo meta:(NSDictionary *)meta {
    //alertView = [UIAlertView alertViewWithTitle:@"Generating postcard..." message:nil cancelButtonTitle:nil otherButtonTitles:nil onDismiss:nil onCancel:nil];

    selectedImage = photo;
    [self imageSaved];

    if (!_currentPostCard.pfObject.objectId) {
        if (!_currentPostCard) {
            [_appDelegate resetPostcard];
        }

        // if postCard doesn't exist on Parse yet, we don't have an image key
        [_currentPostCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            // new postcard must be saved to parse first so we can get a parse ID
            if (!success) {
                //[alertView dismissWithClickedButtonIndex:0 animated:YES];
                [UIAlertView alertViewWithTitle:@"Upload failed" message:@"We could not create a new postcard. Please check your internet connection."];
            }
        }];
    }
}

@end
