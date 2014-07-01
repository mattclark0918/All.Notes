//
//  YTNoteManager.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../CoreData/Classes.h"

@interface YTNoteManager : NSObject

+ (YTNoteManager*) sharedManager;

//creates a new note
- (YTNote*) createNewNote;

//creates a new note copying from other note
- (YTNote*) createNewNoteFrom: (YTNote*) otherNote;

//returns a note by its id
- (YTNote*) getNoteByGuid:(NSString *)noteGuid;

//returns all notes withing some notebook
- (NSArray *)getNotesInNotebook:(YTNotebook *)notebook;

//get favorite notes
- (NSArray*) getFavoriteNotes;

//get all notes with a specific tag name
- (NSArray*) getNotesWithTagName: (NSString*) tagName;

//returns all notes (on the default) notebook
- (NSArray*) getNotes;

//deletes a note
- (BOOL) deleteNote: (YTNote*) note;

//search notes
- (NSArray*) searchNotesWithText: (NSString*) searchTerms;

@end
