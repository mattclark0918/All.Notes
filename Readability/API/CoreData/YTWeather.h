//
//  YTWeather.h
//  Readability
//
//  Created by Maicon Brauwers on 20/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YTEntityBase.h"

@class YTNote;

@interface YTWeather : YTEntityBase

@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * relativeHumidity;
@property (nonatomic, retain) NSNumber * sunriseDate;
@property (nonatomic, retain) NSString * sunriseDateTimezone;
@property (nonatomic, retain) NSString * sunsateDateTimezone;
@property (nonatomic, retain) NSNumber * sunsetDate;
@property (nonatomic, retain) NSNumber * tempCelsius;
@property (nonatomic, retain) NSNumber * tempFahrenheit;
@property (nonatomic, retain) NSString * uniqueIdentifier;
@property (nonatomic, retain) NSNumber * visibilityDistance;
@property (nonatomic, retain) NSString * weatherDescription;
@property (nonatomic, retain) NSNumber * weatherType;
@property (nonatomic, retain) NSNumber * windBearing;
@property (nonatomic, retain) NSNumber * windChillCelsius;
@property (nonatomic, retain) NSNumber * windSpeed;
@property (nonatomic, retain) YTNote *note;

@end
