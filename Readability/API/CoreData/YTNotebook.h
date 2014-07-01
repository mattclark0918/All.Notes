//
//  YTNotebook.h
//  Readability
//
//  Created by Maicon Brauwers on 20/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

@class YTNote;

@interface YTNotebook : YTEntityBase

@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSSet *notes;
@end

@interface YTNotebook (CoreDataGeneratedAccessors)

- (void)addNotesObject:(YTNote *)value;
- (void)removeNotesObject:(YTNote *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

@end
