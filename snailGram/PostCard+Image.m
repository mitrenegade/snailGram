//
//  PostCard+Image.m
//  snailGram
//
//  Created by Bobby Ren on 3/28/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#import "PostCard+Image.h"
#import <objc/runtime.h>

static char const * const ImageFrontTagKey = "ImageFrontTagKey";
static char const * const ImageBackTagKey = "ImageBackTagKey";
static char const * const ImageFullTagKey = "ImageFullTagKey";

@implementation PostCard (Image)

// use associative reference in order to add a new instance variable in a category

-(UIImage *)imageFront {
    return objc_getAssociatedObject(self, ImageFrontTagKey);
}

-(UIImage *)imageBack {
    return objc_getAssociatedObject(self, ImageBackTagKey);
}

-(UIImage *)imageFull {
    return objc_getAssociatedObject(self, ImageBackTagKey);
}

-(void)setImageFront:(UIImage *)image {
    objc_setAssociatedObject(self, ImageFrontTagKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setImageBack:(UIImage *)image {
    objc_setAssociatedObject(self, ImageBackTagKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setImageFull:(UIImage *)image {
    objc_setAssociatedObject(self, ImageFullTagKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
