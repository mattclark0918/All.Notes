//
//  YTEntityBase.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YTEntityBase : NSManagedObject

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * createdDateTimezone;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSString * updatedDateTimezone;

//creates a unique identifier
- (NSString*) createUniqueIdentifier;

- (void) fillCreatedDateTimezone;
- (void) fillUpdatedDateTimezone;


@end
