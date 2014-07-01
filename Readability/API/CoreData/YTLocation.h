//
//  YTLocation.h
//  Readability
//
//  Created by Maicon Brauwers on 20/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

@class YTNote;

@interface YTLocation : YTEntityBase

@property (nonatomic, retain) NSString * admArea;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * foursquareId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locality;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * placeName;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) YTNote *note;

@end
