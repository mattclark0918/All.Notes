//
//  YTNote.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

@class YTAttachment, YTLocation, YTNotebook, YTTag, YTWeather;

@interface YTNote : YTEntityBase

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSSet *attachments;
@property (nonatomic, retain) YTLocation *location;
@property (nonatomic, retain) YTNotebook *notebook;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) YTWeather *weather;

+ (NSString *)titlePlaceholder;

- (NSString*) getDay;
- (NSString*) getWeekday;

@end

@interface YTNote (CoreDataGeneratedAccessors)

- (void)addAttachmentsObject:(YTAttachment *)value;
- (void)removeAttachmentsObject:(YTAttachment *)value;
- (void)addAttachments:(NSSet *)values;
- (void)removeAttachments:(NSSet *)values;

- (void)addTagsObject:(YTTag *)value;
- (void)removeTagsObject:(YTTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
