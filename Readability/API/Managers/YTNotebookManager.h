//
//  YTNotebookManager.h
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Classes.h"
#import "../CoreData/Classes.h"

@interface YTNotebookManager : NSObject {
    YTNotebook* _defaultNotebook;
}

//our singleton
+ (YTNotebookManager*) sharedManager;

//return all notebooks
- (NSArray *) getNotebooks;

//get a specific notebook
- (YTNotebook *) getNotebookByGuid:(NSString *)notebookGuid;

//returns the default notebook
- (YTNotebook*) getDefaultNotebook;

//creates new notebook
- (YTNotebook*) createNewNotebook;

//search for notebooks (if supplied)
- (NSArray*) getNotebooksFilteredBy: (NSString*) searchTerms;

//deletes a notebook
- (void) deleteNotebook: (YTNotebook*) notebook;

@end
