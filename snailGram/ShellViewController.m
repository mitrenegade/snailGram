//
//  ShellViewController.m
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "ShellViewController.h"
#import "FrontEditorViewController.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    selectedImage = [UIImage imageNamed:@"DSC_0377.jpg"];
    if (button == self.buttonCamera) {

    }
    else if (button == self.buttonLibrary) {
        
    }
    if (!self.postCard) {
        self.postCard = (PostCard *)[PostCard createEntityInContext:_appDelegate.managedObjectContext];
        self.postCard.message = @"";
        self.postCard.to = nil;
        self.postCard.from = nil;
        self.postCard.image_url = @""; // todo: upload image to AWS then store url
    }
    [self performSegueWithIdentifier:@"PushFrontEditor" sender:nil];
}

#pragma mark Segue preparation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushFrontEditor"]) {
        FrontEditorViewController *controller = [segue destinationViewController];
        controller.image = selectedImage;
    }
}

@end
