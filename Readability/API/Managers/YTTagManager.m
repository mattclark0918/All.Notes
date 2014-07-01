//
//  YTTagManager.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTTagManager.h"
#import "../CoreData/Classes.h"
#import "Classes.h"

static YTTagManager* _sharedManager;

@implementation YTTagManager

+ (YTTagManager*) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[YTTagManager alloc] init];
    }
    
    return _sharedManager;
}

//searches for a tag by name
- (YTTag*) getTagByName: (NSString*) tagName {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", tagName];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil) {
        if ([fetchedObjects count] > 0) {
            return fetchedObjects[0];
        }
        else {
            return nil;
        }
    }
    else {
        NSLog(@"error while performing getTagByName: %@", error);
        return nil;
    }
}

//return all tags
- (NSArray*) getAllTags: (BOOL) withNotes {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    
    if (withNotes) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"notes.@count > 0"];
        [fetchRequest setPredicate: predicate];
    }
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error while performing getAllTags: %@", error);
        return nil;
    }
    
    return fetchedObjects;
}

//find all tags starting with searchTerms
- (NSArray*) findAllTagsStartingWith: (NSString*) searchTerms {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE \"%@*\"", searchTerms];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error == nil) {
        return fetchedObjects;
    }
    else {
        NSLog(@"error while performing findAllTagsStartingWith: %@", error);
        return nil;
    }
    
}

//creates a new tag
- (YTTag*) createNewTagWithName: (NSString*) tagName {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTTag* tag = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Tag"
                    inManagedObjectContext:context];
    tag.name = tagName;
    tag.createdDate = [NSDate date];
    tag.updatedDate = [NSDate date];
    [tag fillCreatedDateTimezone];
    [tag fillUpdatedDateTimezone];
    return tag;
}

//returns all tags that have names on the set
- (NSArray*) getTagsWithNamesInSet: (NSMutableSet*) tagNamesSet {
    NSLog(@"getTagsWithNamesInSet: %@", tagNamesSet);
    
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name IN %@", tagNamesSet];
    [fetchRequest setPredicate:predicate];
    
    NSLog(@"predicate is %@", predicate);
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"fetched objects count: %lu", (unsigned long)[fetchedObjects count]);
    
    if (error == nil) {
        return fetchedObjects;
    }
    else {
        NSLog(@"error while performing findAllTagsStartingWith: %@", error);
        return nil;
    }
}

@end
