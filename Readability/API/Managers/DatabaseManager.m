
#import "DatabaseManager.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@implementation DatabaseManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContextForBackgroundThread = _managedObjectContextForBackgroundThread;

static DatabaseManager *databaseManager = nil;

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"DatabaseManager::init");
    }
    return self;
}

//setups the database context
- (void) setupContext {
    NSLog(@"DatabaseManager::setupContext");
    
    //to create our managed object context
    [self managedObjectContext];
    
    //creates our managed object context for the background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self managedObjectContextForBackgroundThread];
    });
    
}


+ (DatabaseManager*)sharedManager {
    if (!databaseManager) {
		databaseManager = [[DatabaseManager alloc] init];
	}
	return databaseManager;
}


/**
 * Start of Core Data methods
 */

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
//    NSLog(@"DatabaseManager::managedObjectContext");
//    NSLog(@"current stack is %@", [NSThread callStackSymbols]);
    
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

//this is the context to use on the background thread
//IMPORTANT: this should always be called from PRIORITY_LOW queue
// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContextForBackgroundThread
{
//    NSLog(@"DatabaseManager::managedObjectContextForBackgroundThread");
    
    if (_managedObjectContextForBackgroundThread != nil) {
        return _managedObjectContextForBackgroundThread;
    }

    NSLog(@"setting up managed object context for background thread for the first time");

    NSManagedObjectContext* mainContext = self.managedObjectContext;
    
    if (mainContext != nil) {
        _managedObjectContextForBackgroundThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContextForBackgroundThread setParentContext: mainContext];
    }
    
    return _managedObjectContextForBackgroundThread;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL* storeURL = [self urlForPersistentStore];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//performs an async block on the context main queue and then save
- (void) performBlockAsyncAndSave: (void (^)())block {
    [self.managedObjectContext performBlock:^{
        block();
        NSError* error = nil;
        [self.managedObjectContext save:&error];
        if (error != nil) {
            NSLog(@"Error when performBlockAsyncAndSave: %@", error);
        }
        else {
            NSLog(@"performBlockAsyncAndSave executed successfully");
        }
    }];
}

//performs an async block on the context main queue and then save
- (void) performBlockAsyncAndSave: (void (^)())block WithCompletion: (DatabaseBlock) completionBlock {
    [self.managedObjectContext performBlock:^{
        block();
        NSError* error = nil;
        [self.managedObjectContext save:&error];
        
        BOOL success;
        
        if (error != nil) {
            NSLog(@"Error when performBlockAsyncAndSave: %@", error);
            success = NO;
        }
        else {
            NSLog(@"performBlockAsyncAndSave executed successfully");
            success = YES;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(success);
        });
        
    }];
}

//return the url for the persistent store
- (NSURL*) urlForPersistentStore {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    return storeURL;
}

/**
 * End of Core Data methods
 */

- (void)checkIsMainThread {
	if(![NSThread isMainThread]) {
		NSString *msg = @"EXCEPTION: DatabaseManager: checkIsMainThread: Not main thread";
		NSLog(@"%@", msg);
		[NSException raise:msg format:@""];
	}
}


@end
