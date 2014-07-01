//
//  YTAttachmentOriginalData.h
//  Readability
//
//  Created by Maicon Brauwers on 22/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YTAttachment;

@interface YTAttachmentOriginalData : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) YTAttachment *attachment;

@end
