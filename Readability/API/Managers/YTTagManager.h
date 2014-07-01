//
//  YTTagManager.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../CoreData/Classes.h"

@interface YTTagManager : NSObject

+ (YTTagManager*) sharedManager;

//searches for a tag by name
- (YTTag*) getTagByName: (NSString*) tagName;

//creates a new tag
- (YTTag*) createNewTagWithName: (NSString*) tagName;

//return all tags, optionally only returning tags with registered notes
- (NSArray*) getAllTags: (BOOL) withNotes;

//find all tags starting with searchTerms
- (NSArray*) findAllTagsStartingWith: (NSString*) searchTerms;

//returns all tags that have names on the set
- (NSArray*) getTagsWithNamesInSet: (NSMutableSet*) tagNamesSet;

@end