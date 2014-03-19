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
#import "AWSHelper.h"
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

    [self.canvas.layer setBorderWidth:2];
    [self.buttonReupload setHidden:YES];
    [self.imageView setClipsToBounds:YES];
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
    else if (button == self.buttonReupload) {
        if (!selectedImage)
            [self.buttonReupload setHidden:YES];
        else
            [self didSelectPhoto:selectedImage meta:nil];
    }
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
    alertView = [UIAlertView alertViewWithTitle:@"Generating postcard..." message:nil cancelButtonTitle:nil otherButtonTitles:nil onDismiss:nil onCancel:nil];

    selectedImage = photo;
    [self.imageView setImage:photo];
    [self.buttonReupload setHidden:YES];
    [self.labelInstructions setHidden:YES];
#if AIRPLANE_MODE
    [self imageSaved];
#else
    if (!self.postCard.pfObject.objectId) {
        if (!self.postCard) {
            self.postCard = (PostCard *)[PostCard createEntityInContext:_appDelegate.managedObjectContext];
        }
        self.postCard.message = @"";
        self.postCard.to = nil;
        self.postCard.text = @"";
        self.postCard.image_url = @"";
        self.postCard.image_url_back = @"";

        // if postCard doesn't exist on Parse yet, we don't have an image key
        [self.postCard saveOrUpdateToParseWithCompletion:^(BOOL success) {
            // new postcard must be saved to parse first so we can get a parse ID
            if (success) {
                [self imageSaved];
            }
            else {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
                [UIAlertView alertViewWithTitle:@"Upload failed" message:@"We could not create a new postcard. Please check your internet connection."];
                [self.buttonReupload setHidden:NO];
            }
        }];
    }
    else {
        // if postCard already exists, start image upload
        [self imageSaved];
    }
#endif
}

@end
