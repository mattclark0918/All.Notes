//
//  YTNote.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTNote.h"
#import "YTAttachment.h"
#import "YTLocation.h"
#import "YTNotebook.h"
#import "YTTag.h"
#import "YTWeather.h"


@implementation YTNote

@dynamic content;
@dynamic isFavorite;
@dynamic title;
@dynamic uniqueIdentifier;
@dynamic attachments;
@dynamic location;
@dynamic notebook;
@dynamic tags;
@dynamic weather;

+ (NSString *)titlePlaceholder {
	return NSLocalizedString(@"Untitled Note", nil);
}

- (NSString*) getDay {
    
}

- (NSString*) getWeekday {
    
}

@end
