//
//  YTAttachment.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTAttachment.h"
#import "YTAttachmentMiniPreview.h"
#import "YTAttachmentOriginalData.h"
#import "YTAttachmentPreview.h"
#import "YTNote.h"


@implementation YTAttachment

@dynamic filename;
@dynamic height;
@dynamic type;
@dynamic uniqueIdentifier;
@dynamic width;
@dynamic originalData;
@dynamic note;
@dynamic thumbnail;
@dynamic preview;
@dynamic mini_preview;
@dynamic orientation;

- (BOOL) isImage {
    return [self.type intValue] == YT_ATTACH_TYPE_PHOTO;
}

- (BOOL) isVideo {
    return [self.type intValue] == YT_ATTACH_TYPE_VIDEO;
}

- (BOOL) isAudio {
    return [self.type intValue] == YT_ATTACH_TYPE_AUDIO;
}

- (BOOL) isWebDocViewable {
    return [self.type intValue] == YT_ATTACH_TYPE_WEB_DOC_VIEWABLE;
}

- (BOOL) isOtherType {
    return [self.type intValue] == YT_ATTACH_TYPE_OTHER;
}

- (NSString*) getMimeType {
    NSLog(@"TODO:::getMimeType");
    return @"";
}

- (NSString*) getExtension {
    NSLog(@"TODO::getExtension");
    if ([self isImage]) {
        return @"jpg";
    }
    else if ([self isVideo]) {
        return @"m4v";
    }
    
    return @"";
}


@end
