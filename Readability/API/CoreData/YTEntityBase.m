//
//  YTEntityBase.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTEntityBase.h"
#import "../Base/Classes.h"

@implementation YTEntityBase

@dynamic createdDate;
@dynamic createdDateTimezone;
@dynamic updatedDate;
@dynamic updatedDateTimezone;

//creates a unique identifier
- (NSString*) createUniqueIdentifier {
    return [[VLGuid makeUnique] yoditoToString];
}

- (void) fillCreatedDateTimezone {
    NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
    self.createdDateTimezone = timezone.name;
}

- (void) fillUpdatedDateTimezone {
    NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
    self.updatedDateTimezone = timezone.name;
}

@end
