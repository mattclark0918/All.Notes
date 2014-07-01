//
//  YTNoteManager.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTNoteManager.h"
#import "Classes.h"

static YTNoteManager* _sharedManager;

@implementation YTNoteManager

+ (YTNoteManager*) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[YTNoteManager alloc] init];
    }
    
    return _sharedManager;
}

//creates a new note
- (YTNote*) createNewNote {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTNote* note = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Note"
                        inManagedObjectContext:context];

    note.uniqueIdentifier = [[VLGuid makeUnique] yoditoToString];
    note.notebook = [[YTNotebookManager sharedManager] getDefaultNotebook];
    note.createdDate = [NSDate date];
    note.updatedDate = [NSDate date];
    [note fillCreatedDateTimezone];
    [note fillUpdatedDateTimezone];
    
    return note;
}

//creates a new note copying from other note
- (YTNote*) createNewNoteFrom: (YTNote*) otherNote {
    YTNote* newNote = [self createNewNote];
    newNote.content = otherNote.content;

    //by now we're not copying tags, location and weather yet
    //TODO:::copy tags, location and weather
    NSLog(@"TODO:::copy tags, location and weather");
    
    return newNote;
}

//returns a note by its id
- (YTNote *)getNoteByGuid:(NSString *)noteGuid {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"uniqueIdentifier == %@", noteGuid];
    [fetchRequest setPredicate: predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNoteManager::getNoteByGuid): %@", error);
    }
    
    if ([fetchedObjects count] > 0) {
        return fetchedObjects[0];
    }
    else {
        return nil;
    }
    
}

//returns all notes withing some notebook
- (NSArray *)getNotesInNotebook: (YTNotebook*) notebook {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (notebook != nil) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"notebook == %@", notebook];
        [fetchRequest setPredicate: predicate];
    }
        
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate"
                                                                   ascending:NO];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNoteManager::getNotesInNotebook): %@", error);
    }
    
    /*
    NSLog(@"fetched objects");
    for(YTNote* note in fetchedObjects) {
        NSLog(@"note.createdDate: %@", note.createdDate);
        NSLog(@"note: %@", note);
    }
    */ 
    
    return fetchedObjects;
    
}

//get favorite notes
- (NSArray*) getFavoriteNotes {
    
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //TODO::::see if we need to escape search terms
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isFavorite == YES"];
    [fetchRequest setPredicate: predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate"
                                                                   ascending:NO];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNoteManager::searchNotesWithText): %@", error);
    }
    
    return fetchedObjects;
}

//get all notes with a specific tag name
- (NSArray*) getNotesWithTagName: (NSString*) tagName {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;

    //first read our tag
    YTTag* tag = [[YTTagManager sharedManager] getTagByName: tagName];
    
    if (tag == nil) {
        NSLog(@"ooops, our tag is nil");
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //TODO::::see if we need to escape search terms
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%@ in tags", tag];
    [fetchRequest setPredicate: predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate"
                                                                   ascending:NO];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNoteManager::searchNotesWithText): %@", error);
    }
    
    return fetchedObjects;
    
}

//search notes
- (NSArray*) searchNotesWithText: (NSString*) searchTerms {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    if (searchTerms != nil && [searchTerms length] > 0) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"content beginswith[cd] %@", searchTerms];
        [fetchRequest setPredicate: predicate];
        NSLog(@"predicate: %@", predicate);
    }
    
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate"
                                                                   ascending:NO];
    
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"error fetching objects (on YTNoteManager::searchNotesWithText): %@", error);
    }
    
    return fetchedObjects;
}

//returns all notes (on the default) notebook
- (NSArray*) getNotes {
    return [self getNotesInNotebook: nil];
}

//deletes a note
- (BOOL) deleteNote: (YTNote*) note {
    YTNotebook* notebook = note.notebook;
    [notebook removeNotesObject: note];
    
    NSManagedObjectContext* context = note.managedObjectContext;
    [context deleteObject: note];
    
    NSError* error;
    [context save:&error];
    
    if (error != nil) {
        NSLog(@"Error deleting note: %@", error);
    }
    
    return error == nil;
}


@end