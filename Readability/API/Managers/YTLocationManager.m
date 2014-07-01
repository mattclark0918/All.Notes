//
//  YTLocationManager.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTLocationManager.h"
#import "Classes.h"

static YTLocationManager* _sharedManager;

@implementation YTLocationManager

+ (YTLocationManager*) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[YTLocationManager alloc] init];
    }
    
    return _sharedManager;
}

//creates a new location
- (YTLocation*) createNewLocation {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTLocation* location = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Location"
                    inManagedObjectContext:context];
    
    location.uniqueIdentifier = [[VLGuid makeUnique] yoditoToString];
    location.createdDate = [NSDate date];
    location.updatedDate = [NSDate date];
    [location fillCreatedDateTimezone];
    [location fillUpdatedDateTimezone];
    
    return location;
}

@end
