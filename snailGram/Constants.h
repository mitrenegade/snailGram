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
#define _currentUser [_appDelegate currentUser]

#define MESSAGE_PLACEHOLDER_TEXT @"Enter a message"
#define MESSAGE_LENGTH_LIMIT 40

#define POSTCARD_WIDTH_PIXELS 1800
#define POSTCARD_HEIGHT_PIXELS 1200
#define POSTCARD_IMAGE_WIDTH_PIXELS 1720
#define POSTCARD_IMAGE_HEIGHT_PIXELS 1120

#define DebugLog(...) NSLog(__VA_ARGS__)
#define AIRPLANE_MODE 0
#define CAN_LOAD_POSTCARD 0
#define TESTING 0
#define USE_PAYPAL 1

#define FONT_ITALIC(x) [UIFont fontWithName:@"OpenSansLight-Italic" size:x]
#define FONT_BOLD(x) [UIFont fontWithName:@"OpenSans-Bold" size:x]
#define FONT_REGULAR(x) [UIFont fontWithName:@"OpenSans" size:x]
#define FONT_LIGHT(x) [UIFont fontWithName:@"OpenSans-Light" size:x]

// pasteboard
#define PASTEBOARD_NAME @"com.snailgram.app.pasteboard"
#define PASTEBOARD_KEY_USERID @"com.snailgram.app.user.id"
#endif
