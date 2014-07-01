//
//  YTNotebookManager.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTNotebookManager.h"

static YTNotebookManager* _sharedManager;

@implementation YTNotebookManager

+ (YTNotebookManager*) sharedManager {

    if (_sharedManager == nil) {
        _sharedManager = [[YTNotebookManager alloc] init];
    }
    
    return _sharedManager;
}

//return all notebooks
- (NSArray *) getNotebooks {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    if (error != nil) {
        NSLog(@"error fetching objects (on YTNotebookManager::getNotebooks): %@", error);
    }
    
    return fetchedObjects;
    
}

//search for notebooks (if supplied)
- (NSArray*) getNotebooksFilteredBy: (NSString*) searchTerms {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (searchTerms != nil && [searchTerms length] > 0) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchTerms];
        [fetchRequest setPredicate: predicate];
    }
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNotebookManager::getNotebooks): %@", error);
    }
    
    return fetchedObjects;
}


//get a specific notebook
- (YTNotebook *) getNotebookByGuid:(NSString *)notebookGuid {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Notebook" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", notebookGuid];
    [fetchRequest setPredicate: predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNotebookManager::getNotebookByGuid): %@", error);
    }
    
    if ([fetchedObjects count] > 0) {
        return fetchedObjects[0];
    }
    else {
        return nil;
    }
    
}

//returns the default notebook
- (YTNotebook*) getDefaultNotebook {
    
    if (_defaultNotebook == nil) {
        [self setupDefaultNotebook];
    }
    
    if (_defaultNotebook == nil) {
        NSLog(@"Error:::: default notebook is nil");
    }
    
    return _defaultNotebook;
}

//setups the default notebook and caches it
- (YTNotebook*) setupDefaultNotebook {
    NSArray* allNotebooks = [self getNotebooks];
 
    //TODO:::research
    //Old code looked for a notebookinfo witu isDefault attribute
    
    if ([allNotebooks count] > 0) {
        _defaultNotebook = allNotebooks[0];
        return _defaultNotebook;
    }
    else {
        NSLog(@"Ooops, we don't have any notebook. YTNotebookManager::setupDefaultNotebook");
        [self createDefaultNotebook];
        
        if (_defaultNotebook != nil) {
            NSLog(@"now we have a notebook");
        }
        else {
            NSLog(@"we still don't have a notebook");
        }
        
        return _defaultNotebook;
    }
    
}

//creates default notebook
- (void) createDefaultNotebook {
    YTNotebook* notebook = [self createNewNotebook];
    _defaultNotebook = notebook;
    [[DatabaseManager sharedManager] saveContext];
}

//creates new notebook
- (YTNotebook*) createNewNotebook {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTNotebook* notebook = [NSEntityDescription
                    insertNewObjectForEntityForName:@"Notebook"
                    inManagedObjectContext:context];
    
    notebook.uniqueIdentifier = [[VLGuid makeUnique] yoditoToString];
    notebook.createdDate = [NSDate date];
    notebook.updatedDate = [NSDate date];
    [notebook fillCreatedDateTimezone];
    [notebook fillUpdatedDateTimezone];
    
    return notebook;
}

//deletes a notebook
- (void) deleteNotebook: (YTNotebook*) notebook {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    [context deleteObject: notebook];
    [[DatabaseManager sharedManager] saveContext];
}


@end
