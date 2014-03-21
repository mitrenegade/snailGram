//
//  Constants.h
//  snailGram
//
//  Created by Bobby Ren on 3/1/14.
//  Copyright (c) 2014 SnailGram. All rights reserved.
//

#ifndef snailGram_Constants_h
#define snailGram_Constants_h

#define _appDelegate ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define _currentPostCard [_appDelegate postCard]

#define MESSAGE_PLACEHOLDER_TEXT @"Please enter a message"
#define MESSAGE_LENGTH_LIMIT 500

#define DebugLog(...) NSLog(__VA_ARGS__)
#define AIRPLANE_MODE 0
#define USE_PAYPAL 0
#endif
