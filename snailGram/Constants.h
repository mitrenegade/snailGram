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

#define MESSAGE_PLACEHOLDER_TEXT @"Please enter a message"
#define MESSAGE_LENGTH_LIMIT 500

#define DebugLog(...) NSLog(__VA_ARGS__)
#define AIRPLANE_MODE 0

#define FONT_ITALIC(x) [UIFont fontWithName:@"OpenSansLight-Italic" size:x]
#define FONT_BOLD(x) [UIFont fontWithName:@"OpenSans-Bold" size:x]
#define FONT_REGULAR(x) [UIFont fontWithName:@"OpenSans" size:x]
#define FONT_LIGHT(x) [UIFont fontWithName:@"OpenSans-Light" size:x]

// pasteboard
#define PASTEBOARD_NAME @"com.snailgram.app.pasteboard"
#define PASTEBOARD_KEY_USERID @"com.snailgram.app.user.id"
#endif
