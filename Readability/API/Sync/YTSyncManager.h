//
//  IDMSyncManager.h
//  Idiomatic
//
//  Created by Drew McCormack on 04/03/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ensembles.h"
#import "../Settings/YTSettingsManager.h"

extern NSString * const YTSyncActivityDidBeginNotification;
extern NSString * const YTSyncActivityDidEndNotification;

@interface YTSyncManager : NSObject

@property (nonatomic, readonly, strong) CDEPersistentStoreEnsemble *ensemble;
@property (nonatomic, readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite, copy) NSString *storePath;

+ (instancetype)sharedSyncManager;

- (void)connectToSyncService:(YTSyncBackendMode) backendMode withCompletion:(CDECompletionBlock)completion;
- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion;

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion;
- (BOOL)canSynchronize;

- (void)setup;
- (void)reset;

//are we currently syncing?
- (BOOL) isSyncing;

//- (BOOL)handleOpenURL:(NSURL *)url;

@end
