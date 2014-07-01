//
//  YTTag.h
//  Readability
//
//  Created by Maicon Brauwers on 20/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

@class YTNote;

@interface YTTag : YTEntityBase

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *notes;
@end

@interface YTTag (CoreDataGeneratedAccessors)

- (void)addNotesObject:(YTNote *)value;
- (void)removeNotesObject:(YTNote *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
