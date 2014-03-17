//
//  FlipSegue.m
//  snailGram
//
//  Created by Bobby Ren on 3/16/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "FlipSegue.h"

@implementation FlipSegue

- (void)perform {
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    [UIView transitionWithView:src.navigationController.view duration:0.25
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        [src.navigationController pushViewController:dst animated:NO];
                    }
                    completion:NULL];
}

@end
