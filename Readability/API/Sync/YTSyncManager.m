//
//  IDMSyncManager.m
//  Idiomatic
//
//  Created by Drew McCormack on 04/03/14.
//  Copyright (c) 2014 The Mental Faculty B.V. All rights reserved.
//

#import <CoreData/CoreData.h>
//#import <DropboxSDK/DropboxSDK.h>
#import <Security/Security.h>
#import "YTSyncManager.h"
//#import "CDEDropboxCloudFileSystem.h"
#import "../CoreData/Classes.h"
#import "../Managers/DatabaseManager.h"
#import "../Settings/YTSettingsManager.h"

NSString * const YTSyncActivityDidBeginNotification = @"YTSyncActivityDidBegin";
NSString * const YTSyncActivityDidEndNotification = @"YTSyncActivityDidEnd";

// Set these with your account details
NSString * const YTICloudContainerIdentifier = @"N6FA87RQ3K.com.alephgames.allnotes";
//NSString * const YTDropboxAppKey = @"fjgu077wm7qffv0";
//NSString * const YTDropboxAppSecret = @"djibc9zfvppronm";

@interface YTSyncManager () <CDEPersistentStoreEnsembleDelegate>/*, DBSessionDelegate, CDEDropboxCloudFileSystemDelegate*/

@end

@implementation YTSyncManager {
    CDEICloudFileSystem *cloudFileSystem;
    NSUInteger activeMergeCount;
//    CDECompletionBlock dropboxLinkSessionCompletion;
//    DBSession *dropboxSession;
}

@synthesize ensemble = ensemble;
@synthesize storePath = storePath;
@synthesize managedObjectContext = managedObjectContext;

+ (instancetype)sharedSyncManager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YTSyncManager alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Setting Up and Resetting

- (void)setup
{
    [self setupEnsemble];
}

- (void)reset
{
//    [dropboxSession unlinkAll];
//    dropboxSession = nil;
    ensemble.delegate = nil;
    ensemble = nil;
}

#pragma mark - Connecting to a Backend Service

- (void)connectToSyncService:(YTSyncBackendMode) backendMode withCompletion:(CDECompletionBlock)completion
{
    [self setupEnsemble];
    [self synchronizeWithCompletion:completion];
}

- (void)disconnectFromSyncServiceWithCompletion:(CDECodeBlock)completion
{
    [ensemble deleechPersistentStoreWithCompletion:^(NSError *error) {
        [self reset];
        if (completion) completion();
    }];
}

#pragma mark - Persistent Store Ensemble

- (void)setupEnsemble
{
    
    // Ensembles logging
    CDESetCurrentLoggingLevel(CDELoggingLevelVerbose);
    
    if (![self canSynchronize]) return;
    
    cloudFileSystem = [self makeCloudFileSystem];
    if (!cloudFileSystem) { NSLog(@"early return"); return; }
     
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    ensemble = [[CDEPersistentStoreEnsemble alloc] initWithEnsembleIdentifier:@"MainStore" persistentStoreURL:storeURL managedObjectModelURL:modelURL cloudFileSystem:cloudFileSystem];
    ensemble.delegate = self;
}

- (id <CDECloudFileSystem>)makeCloudFileSystem
{
    id <CDECloudFileSystem> newSystem = nil;
    
    if ([YTSettingsManager shared].syncBackendMode == kYTSyncBackendICloud) {
        NSLog(@"creating cloud file system of type iCloud");
        newSystem = [[CDEICloudFileSystem alloc] initWithUbiquityContainerIdentifier:YTICloudContainerIdentifier];
    }
    else {
        NSLog(@"ooops, did not found what file cloud system we should create");
    }
    /*
    else if ([cloudService isEqualToString:IDMDropboxService]) {
        dropboxSession = [[DBSession alloc] initWithAppKey:IDMDropboxAppKey appSecret:IDMDropboxAppSecret root:kDBRootAppFolder];
        dropboxSession.delegate = self;
        CDEDropboxCloudFileSystem *newDropboxSystem = [[CDEDropboxCloudFileSystem alloc] initWithSession:dropboxSession];
        newDropboxSystem.delegate = self;
        newSystem = newDropboxSystem;
    }
    */
    return newSystem;
}

#pragma mark - Sync Methods

- (BOOL)canSynchronize
{
    return [YTSettingsManager shared].syncBackendMode == kYTSyncBackendICloud;
}

- (void)synchronizeWithCompletion:(CDECompletionBlock)completion
{
    NSLog(@"synchronizeWithCompletion");
    
    if (![self canSynchronize]) return;
    
    [self incrementMergeCount];
    if (!ensemble.isLeeched) {
        NSLog(@"ensemble leech");
        [ensemble leechPersistentStoreWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if (error) {
                NSLog(@"Could not leech to ensemble: %@", error);
                [self disconnectFromSyncServiceWithCompletion:^{
                    if (completion) completion(error);
                }];
            }
            else {
                if (completion) completion(error);
            }
        }];
    }
    else {
        NSLog(@"ensemble merge");
        [ensemble mergeWithCompletion:^(NSError *error) {
            [self decrementMergeCount];
            if (error) NSLog(@"Error merging: %@", error);
            if (completion) completion(error);
        }];
    }
}

- (void)decrementMergeCount
{
    activeMergeCount--;
    if (activeMergeCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YTSyncActivityDidEndNotification object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)incrementMergeCount
{
    activeMergeCount++;
    if (activeMergeCount == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:YTSyncActivityDidBeginNotification object:nil];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

#pragma mark - Persistent Store Ensemble Delegate

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didSaveMergeChangesWithNotification:(NSNotification *)notification
{
    
    NSLog(@"didSaveMergeChangesWithNotification");

    //this is called after a merge, to make local context reflect merged changes
    //it looks we need to merge all contexts, including our background one

//    [[[DatabaseManager sharedManager] managedObjectContextForBackgroundThread] performBlock:^{
//        NSLog(@"Merging background context. Is this the main thread? %d", [NSThread isMainThread]);
//        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
//    }];
    
    [managedObjectContext performBlock:^{
        NSLog(@"Mergin main context. Is this the main thread? %d", [NSThread isMainThread]);
        [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }];
}

- (NSArray *)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble globalIdentifiersForManagedObjects:(NSArray *)objects
{
    NSLog(@"globalIdentifiersForManagedObjects");
    
    NSMutableArray* globalIds = [NSMutableArray array];
    for(NSManagedObject* obj in objects) {
        if ([obj isKindOfClass: [YTTag class]]) {
            NSLog(@"its a tag");
            YTTag* tag = (YTTag*) obj;
            [globalIds addObject: tag.name];
        }
        else if ([obj isKindOfClass: [YTAttachmentMiniPreview class]]) {
            NSLog(@"its a mini preview");
            YTAttachmentMiniPreview* miniPreview = (YTAttachmentMiniPreview*) obj;
            NSString* strId = [NSString stringWithFormat:@"%@_mini_preview", miniPreview.attachment.uniqueIdentifier];
            [globalIds addObject: strId];
        }
        else if ([obj isKindOfClass: [YTAttachmentPreview class]]) {
            NSLog(@"its a preview");
            YTAttachmentPreview* preview = (YTAttachmentPreview*) obj;
            NSString* strId = [NSString stringWithFormat:@"%@_preview", preview.attachment.uniqueIdentifier];
            [globalIds addObject: strId];
        }
        else if ([obj isKindOfClass: [YTAttachmentOriginalData class]]) {
            NSLog(@"its a original data");
            YTAttachmentOriginalData* original = (YTAttachmentOriginalData*) obj;
            NSString* strId = [NSString stringWithFormat:@"%@_original", original.attachment.uniqueIdentifier];
            [globalIds addObject: strId];
        }
        else {
            NSLog(@"its another object with uniqueIdentifier");
            //all other objects have unique identifier
            [globalIds addObject: [obj valueForKeyPath:@"uniqueIdentifier"]];
        }
    }

    NSLog(@"global ids: %@", globalIds);
    
    return globalIds;
}

- (void)persistentStoreEnsemble:(CDEPersistentStoreEnsemble *)ensemble didDeleechWithError:(NSError *)error
{
    NSLog(@"Store did deleech with error: %@", error);
    [self reset];
}

//are we currently syncing?
- (BOOL) isSyncing {
    return activeMergeCount > 0;
}

#pragma mark - Dropbox Session

/*
- (BOOL)handleOpenURL:(NSURL *)url {
    if ([dropboxSession handleOpenURL:url]) {
		if ([dropboxSession isLinked]) {
            if (dropboxLinkSessionCompletion) dropboxLinkSessionCompletion(nil);
		}
        else {
            NSError *error = [NSError errorWithDomain:CDEErrorDomain code:CDEErrorCodeAuthenticationFailure userInfo:nil];
            if (dropboxLinkSessionCompletion) dropboxLinkSessionCompletion(error);
        }
        dropboxLinkSessionCompletion = NULL;
		return YES;
    }
    return NO;
}

- (void)linkSessionForDropboxCloudFileSystem:(CDEDropboxCloudFileSystem *)fileSystem completion:(CDECompletionBlock)completion
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    dropboxLinkSessionCompletion = [completion copy];
    [dropboxSession linkFromController:window.rootViewController];
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId
{
}
 */

@end
