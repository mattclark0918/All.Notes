
#import <Foundation/Foundation.h>
#import "../Classes.h"

typedef void (^DatabaseBlock)(BOOL);

@interface DatabaseManager : NSObject

//Core Data related props
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//managed object context for background thread (QUEUE_PRIORITY_LOW)
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContextForBackgroundThread;

//our singleton
+ (DatabaseManager*)sharedManager;

//setups the database context
- (void) setupContext;

//saves the context
- (void) saveContext;

//performs an async block on the context main queue and then save
- (void) performBlockAsyncAndSave: (void (^)())block WithCompletion: (DatabaseBlock) completionBlock;

//checkes to see if we're on the main thread
- (void)checkIsMainThread;

//return the url for the persistent store
- (NSURL*) urlForPersistentStore;

@end
