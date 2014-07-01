//
//  YTAttachment.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

typedef enum {
    YT_ATTACH_TYPE_UNKNOWN = 0,
    YT_ATTACH_TYPE_PHOTO,
    YT_ATTACH_TYPE_VIDEO,
    YT_ATTACH_TYPE_WEB_DOC_VIEWABLE,
    YT_ATTACH_TYPE_AUDIO,
    YT_ATTACH_TYPE_OTHER
} YTAttachmentType;

@class YTNote;

@class YTAttachmentMiniPreview, YTAttachmentOriginalData, YTAttachmentPreview, YTAttachmentThumbnail, YTNote;

@interface YTAttachment : YTEntityBase

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * orientation;
@property (nonatomic, retain) YTAttachmentOriginalData *originalData;
@property (nonatomic, retain) YTNote *note;
@property (nonatomic, retain) YTAttachmentThumbnail *thumbnail;
@property (nonatomic, retain) YTAttachmentPreview *preview;
@property (nonatomic, retain) YTAttachmentMiniPreview *mini_preview;

- (BOOL) isImage;
- (BOOL) isVideo;
- (BOOL) isAudio;
- (BOOL) isWebDocViewable;
- (BOOL) isOtherType;

- (NSString*) getMimeType;
- (NSString*) getExtension;

@end
