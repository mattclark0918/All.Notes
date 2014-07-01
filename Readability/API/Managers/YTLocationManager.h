//
//  YTLocationManager.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../CoreData/Classes.h"

@interface YTLocationManager : NSObject

+ (YTLocationManager*) sharedManager;

//creates a new location
- (YTLocation*) createNewLocation;

@end
