//
//  YTAttachmentManager.m
//  Readability
//
//  Created by Maicon Brauwers on 19/05/14.
//  Copyright (c) 2014 Victor Zyabko. All rights reserved.
//

#import "YTAttachmentManager.h"

static YTAttachmentManager* _sharedManager;

@implementation YTAttachmentManager

+ (YTAttachmentManager*) sharedManager {
    if (_sharedManager == nil) {
        _sharedManager = [[YTAttachmentManager alloc] init];
    }
    
    return _sharedManager;
}

//return attachments for a certain note and of a certain type
- (NSArray*) getAttachmentsFromNote: (YTNote*) note OfType: (YTAttachmentType) type {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"note == %@", note];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"filename"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

    if (error != nil) {
        NSLog(@"Error fetching on getAttachmentsFromNote: %@", error);
    }
    
    return fetchedObjects;
}

//returns all attachments
- (NSArray*) getAllAttachments {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attachment" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"filename"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil) {
        NSLog(@"Error fetching on getAttachmentsFromNote: %@", error);
    }
    
    return fetchedObjects;
}

//deletes an attachment
- (void) deleteAttachment: (YTAttachment*) attachment {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTNote* note = attachment.note;
    [note removeAttachmentsObject: attachment];

    [context deleteObject: attachment];
    
    [[DatabaseManager sharedManager] saveContext];
}

//add an image attachment to a note
- (void) addImageAttachment: (UIImage*) image ToNote: (YTNote*) note ResultBlock: (VoidBlock) resultBlock {
    NSLog(@"addImageAttachment");
    
    //first we create different versions of our image on a background thread
    //we do image manipulation code on a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSData* originalImgData = UIImageJPEGRepresentation(image, kYTDefaultJpegImageQuality);
        
        if (originalImgData == nil) { NSLog(@"oooops, original img data is nil"); }
        else { NSLog(@"original img data is ok"); }
        
        @autoreleasepool {
        
            //resize to preview size
            __block NSData* previewData = [self createPreviewDataFrom: image];
            if (previewData == nil) { NSLog(@"ooops, preview data is nil"); }
            else { NSLog(@"preview data is ok"); }

            UIImage* previewImage = [UIImage imageWithData: previewData];
            
            //resize to mini preview size
            __block NSData* miniPreviewData = [self createMiniPreviewDataFrom: previewImage];
            if (miniPreviewData == nil) { NSLog(@"ooops, mini preview data is nil"); }
            else { NSLog(@"mini preview data is ok"); }
            
            previewImage = nil;
            
            //resize to thumbnail size
            //we're not saving thumbnail size
            //resize to preview size
            //__block NSData* thumbData = [self createThumbnailDataFrom: image];
            //if (thumbData == nil) { NSLog(@"ooops, thumbnail data is nil"); }
            //else { NSLog(@"thumbnail data is ok"); }
            
            //now we store on the database
            //database code on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //main attachment object
                YTAttachment* attachment = [self createNewAttachment];
                attachment.width = [NSNumber numberWithInt: (int) image.size.width];
                attachment.height = [NSNumber numberWithInt: (int) image.size.height];
                attachment.type = [NSNumber numberWithInt:YT_ATTACH_TYPE_PHOTO];
                attachment.uniqueIdentifier = [attachment createUniqueIdentifier];
                NSLog(@"image orientation is %d", (int) image.imageOrientation);
                attachment.orientation = [NSNumber numberWithInt: (int) image.imageOrientation];
                [note addAttachmentsObject: attachment];
                
                //original img data
                YTAttachmentOriginalData* attachmentOriginal = [self createNewAttachmentOriginalData];
                attachmentOriginal.data = originalImgData;
                attachment.originalData = attachmentOriginal;
                originalImgData = nil;
                
                //preview data
                YTAttachmentPreview* attachmentPreview = [self createNewAttachmentPreview];
                attachmentPreview.data = previewData;
                attachment.preview = attachmentPreview;
                previewData = nil;
                
                //thumbnail data
                //YTAttachmentThumbnail* attachmentThumb = [self createNewAttachmentThumbnail];
                //attachmentThumb.data = thumbData;
                //attachment.thumbnail = attachmentThumb;
                //thumbData = nil;
                
                //mini-preview data
                YTAttachmentMiniPreview* attachmentMiniPreview = [self createNewAttachmentMiniPreview];
                attachmentMiniPreview.data = miniPreviewData;
                attachment.mini_preview = attachmentMiniPreview;
                miniPreviewData = nil;
                
                //commit changes to database
                [[DatabaseManager sharedManager] saveContext];
                
                //pull objects from memoty
                NSManagedObjectContext* context = [[DatabaseManager sharedManager] managedObjectContext];
                [context refreshObject:attachmentOriginal mergeChanges:NO];
                //[context refreshObject:attachmentThumb mergeChanges:NO];
                [context refreshObject:attachmentPreview mergeChanges:NO];
                [context refreshObject:attachmentMiniPreview mergeChanges:NO];
                
                //calls result block
                resultBlock();
            });
        }
    });

}

//add a video attachment to a note
- (void) addVideoAttachment: (NSString*) pathToVideo ToNote: (YTNote*) note ResultBlock: (VoidBlock) resultBlock {
    NSLog(@"addVideoAttachment");

    //first we load video data to memory
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError* error;
        NSData* videoData = [NSData dataWithContentsOfFile:pathToVideo options:NSDataReadingUncached error:&error];
        
        if (error != nil) {
            NSLog(@"error reading video data: %@", error);
            return;
        }
        
        //now we store on the database
        //database code on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //main attachment object
            YTAttachment* attachment = [self createNewAttachment];
//            attachment.width = [NSNumber numberWithInt: (int) image.size.width];
//            attachment.height = [NSNumber numberWithInt: (int) image.size.height];
            attachment.type = [NSNumber numberWithInt:YT_ATTACH_TYPE_PHOTO];
            [note addAttachmentsObject: attachment];
        
            //original img data
            YTAttachmentOriginalData* attachmentOriginal = [self createNewAttachmentOriginalData];
            attachmentOriginal.data = videoData;
            attachment.originalData = attachmentOriginal;
            
            //commit changes to database
            [[DatabaseManager sharedManager] saveContext];
            
            //refreshes the object from the database
            [[DatabaseManager sharedManager].managedObjectContext refreshObject:attachmentOriginal mergeChanges:NO];
            
            //calls result block
            resultBlock();
        });
    });
    
}

//creates a new attachment main object
- (YTAttachment*) createNewAttachment {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTAttachment* attachment = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Attachment"
                                    inManagedObjectContext:context];
    attachment.createdDate = [NSDate date];
    attachment.updatedDate = [NSDate date];
    [attachment fillCreatedDateTimezone];
    [attachment fillUpdatedDateTimezone];
    return attachment;
}

//creates a new attachment original data object
//this is the attachment sub object that stores the original, full and non modified data
- (YTAttachmentOriginalData*) createNewAttachmentOriginalData {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTAttachmentOriginalData* attachmentOriginalData =
                                [NSEntityDescription
                                    insertNewObjectForEntityForName:@"AttachmentOriginalData"
                                    inManagedObjectContext:context];
    return attachmentOriginalData;
}

//creates a new attachment preview object
//this is the attachment sub object that stores the image at preview size
- (YTAttachmentPreview*) createNewAttachmentPreview {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTAttachmentPreview* attachmentPreview =
                                    [NSEntityDescription
                                     insertNewObjectForEntityForName:@"AttachmentPreview"
                                     inManagedObjectContext:context];
    return attachmentPreview;
}

//creates a new attachment mini preview object
//this is the attachment sub object that stores the image at mini preview size
- (YTAttachmentMiniPreview*) createNewAttachmentMiniPreview {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTAttachmentMiniPreview* attachmentMiniPreview =
                                    [NSEntityDescription
                                     insertNewObjectForEntityForName:@"AttachmentMiniPreview"
                                     inManagedObjectContext:context];
    return attachmentMiniPreview;
}

//creates a new attachment thumbnail object
//this is the attachment sub object that stores the image at thumbnail size
- (YTAttachmentThumbnail*) createNewAttachmentThumbnail {
    NSManagedObjectContext* context = [DatabaseManager sharedManager].managedObjectContext;
    
    YTAttachmentThumbnail* attachmentThumbnail =
                                    [NSEntityDescription
                                     insertNewObjectForEntityForName:@"AttachmentThumbnail"
                                     inManagedObjectContext:context];
    return attachmentThumbnail;
}

//resizes image to preview size and returns its data
- (NSData*) createPreviewDataFrom: (UIImage*) image {
    CGSize imageSize = image.size;
    
    float previewMaxSide = kYTPhotoPreviewMaxWidth;
    if(imageSize.width < imageSize.height)
        previewMaxSide = kYTPhotoPreviewMaxWidth * imageSize.height / imageSize.width;
    previewMaxSide = round(previewMaxSide);
    if(previewMaxSide < 1)
        previewMaxSide = 1;

    NSLog(@"preview mas side is %f", previewMaxSide);
    
    UIImage *imagePreview = [image limitSizeAndRotate:previewMaxSide];
    return UIImageJPEGRepresentation(imagePreview, kYTDefaultJpegImageQuality);
}

//resizes image to mini preview size and returns its data
- (NSData*) createMiniPreviewDataFrom: (UIImage*) image {
    UIImage *imageMiniPreview = [image limitSizeAndRotate:kYTPhotoMiniPreviewMaxSide];
    return UIImageJPEGRepresentation(imageMiniPreview, kYTDefaultJpegImageQuality);
}

//resizes image to thumbnail size and returns its data
- (NSData*) createThumbnailDataFrom: (UIImage*) image {
    
    CGSize thumbSize = kYTPhotoThumbnailSize;
    UIViewContentMode contentMode = UIViewContentModeScaleAspectFill;
    
	CGSize imageSize = image.size;
	float imageScale = MAX(imageSize.width, 1) / MAX(imageSize.height, 1);
	float thumbScale = MAX(thumbSize.width, 1) / MAX(thumbSize.height, 1);
	float maxThumbSide = MAX(thumbSize.width, thumbSize.height);
	if(contentMode == UIViewContentModeScaleAspectFit) {
		if(thumbScale >= imageScale)
			maxThumbSide = thumbSize.width;
		else
			maxThumbSide = thumbSize.height;
	}
	else if(contentMode == UIViewContentModeScaleAspectFill) {
		if(thumbScale >= imageScale)
			maxThumbSide = MAX(thumbSize.width, (thumbSize.width / imageScale));
		else
			maxThumbSide = MAX(thumbSize.height, (thumbSize.height * imageScale));
	}
	
	// If image is smaller than thumbnail
	float imageMaxSide = MAX(imageSize.width, imageSize.height);
	if(maxThumbSide > imageMaxSide)
	{
		float ratio = imageMaxSide / maxThumbSide;
		maxThumbSide *= ratio;
		thumbSize.width *= ratio;
		thumbSize.height *= ratio;
	}
	
	maxThumbSide = round(maxThumbSide);
	if(maxThumbSide < 1)
		maxThumbSide = 1;
	thumbSize.width = round(thumbSize.width);
	if(thumbSize.width < 1)
		thumbSize.width = 1;
	thumbSize.height = round(thumbSize.height);
	if(thumbSize.height < 1)
		thumbSize.height = 1;
	
    NSLog(@"thumbnail size is %fx%f", thumbSize.width, thumbSize.height);
    
	UIImage *thumbnail = [image limitSizeAndRotate:maxThumbSide];
	CGSize thumbnailSize = thumbnail.size;
	if(contentMode == UIViewContentModeScaleAspectFill && imageScale != thumbScale) {
		CGRect rectCrop = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
		rectCrop.origin.x = thumbnailSize.width/2 - rectCrop.size.width/2;
		rectCrop.origin.y = thumbnailSize.height/2 - rectCrop.size.height/2;
		
		rectCrop.origin.x = round(rectCrop.origin.x);
		rectCrop.origin.y = round(rectCrop.origin.y);
		rectCrop.size.width = round(rectCrop.size.width);
		if(rectCrop.size.width < 1)
			rectCrop.size.width = 1;
		rectCrop.size.height = round(rectCrop.size.height);
		if(rectCrop.size.height < 1)
			rectCrop.size.height = 1;
		
		CGImageRef imageRef = CGImageCreateWithImageInRect(thumbnail.CGImage, rectCrop);
		thumbnail = [UIImage imageWithCGImage:imageRef];
		//thumbnailSize = thumbnail.size;
		CGImageRelease(imageRef);
	}
    
    return UIImageJPEGRepresentation(thumbnail, kYTDefaultJpegImageQuality);
}



@end
