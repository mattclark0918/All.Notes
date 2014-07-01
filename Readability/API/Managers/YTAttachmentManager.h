//
//  YTAttachmentManager.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Classes.h"

typedef void (^VoidBlock)(void);

@interface YTAttachmentManager : NSObject

+ (YTAttachmentManager*) sharedManager;

//return attachments for a certain note and of a certain type
- (NSArray*) getAttachmentsFromNote: (YTNote*) note OfType: (YTAttachmentType) type;

//returns all attachments
- (NSArray*) getAllAttachments;

//deletes an attachment
- (void) deleteAttachment: (YTAttachment*) attachment;

//add an image attachment to a note
- (void) addImageAttachment: (UIImage*) image ToNote: (YTNote*) note ResultBlock: (VoidBlock) resultBlock;

//add a video attachment to a note
- (void) addVideoAttachment: (NSString*) pathToVideo ToNote: (YTNote*) note ResultBlock: (VoidBlock) resultBlock;


@end
