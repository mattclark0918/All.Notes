
#import "YTUiMediator.h"
#import "AppDelegate.h"

#define kSavedDataKey @"YTUiMediator"
#define kSavedDataVersion (kYTManagersBaseVersion + 4)

static YTUiMediator *_shared;

@implementation YTUiMediator

@synthesize msgrNoteAddedManually = _msgrNoteAddedManually;
@synthesize msgrFileCantBeViewedAlerted = _msgrFileCantBeViewedAlerted;
@synthesize msgrScrollingEnded = _msgrScrollingEnded;

+ (YTUiMediator *)shared {
	if(!_shared) {
		_shared = [VLObjectFileStorage loadRootObjectWithKey:kSavedDataKey version:kSavedDataVersion];
		if(!_shared)
			_shared = [[YTUiMediator alloc] init];
	}
	return _shared;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super init];
	if(self) {
		_shared = self;
		
		if(aDecoder) {
			
		}
		
		_msgrNoteAddedManually = [[VLMessenger alloc] init];
		_msgrNoteAddedManually.owner = self;
		_msgrFileCantBeViewedAlerted = [[VLMessenger alloc] init];
		_msgrFileCantBeViewedAlerted.owner = self;
		_msgrScrollingEnded = [[VLMessenger alloc] init];
		_msgrScrollingEnded.owner = self;
		
//		[[YTNotebooksEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotebooksManagerChanged:)];
//		[[YTNotesEnManager shared].msgrVersionChanged addObserver:self selector:@selector(onNotesManagerChanged:)];
		[[YTApiMediator shared].msgrVersionChanged addObserver:self selector:@selector(onApiMediatorChanged:)];
		
		[self.msgrVersionChanged addObserver:self selector:@selector(onVersionChanged:)];
		_savedDataVersion = self.version;
	}
	return self;
}

- (id)init {
	return [self initWithCoder:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	
}

- (void)onVersionChanged:(id)sender {
	/*if(_savedDataVersion != self.version) {
		[VLObjectFileStorage saveDataWithRootObject:self key:kSavedDataKey version:kSavedDataVersion];
		_savedDataVersion = self.version;
	}*/
}

- (void)onNotebooksManagerChanged:(id)sender {
	[self modifyVersion];
}

- (void)onNotesManagerChanged:(id)sender {
	[self modifyVersion];
}

- (void)onApiMediatorChanged:(id)sender {
	[self modifyVersion];
}

- (YTNotebook *)notebookForNewNotes {
    return [[YTNotebookManager sharedManager] getDefaultNotebook];
}

/*
- (YTStackInfo *)mainStack {
	NSArray *stacks = [[YTStacksEnManager shared] getStacks];
	if(stacks.count)
		return [stacks objectAtIndex:0];
	return nil;
}
*/
 
- (void)deleteNoteWithNoteView:(YTNoteView *)noteView resultBlock:(VLBlockBool)resultBlock {
	YTNote *note = noteView.note;
	VLActionSheet *actions = [[VLActionSheet alloc] init];
	[actions addButtonWithTitle:NSLocalizedString(@"Delete {Button}", nil)];
	[actions addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
	actions.destructiveButtonIndex = 0;
	actions.cancelButtonIndex = 1;
	[actions showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
		if(btnIndex == 0) {
            [[YTNoteManager sharedManager] deleteNote: note];
            resultBlock(YES);
		}
	}];
}

- (void)pushNewNoteEditView:(YTNoteEditView *)noteEditView {
	[[YTSlidingContainerView shared] showNoteEditView:noteEditView];
}

- (void)startAddNewNoteAsPhotoWithSource:(UIImagePickerControllerSourceType)sourceType
					 previousScreenTitle:(NSString *)previousScreenTitle{
    
	[[VLMessageCenter shared] performBlock:^{
		if(sourceType == UIImagePickerControllerSourceTypeCamera) {
			self.picker = [[YTImagePickerController alloc] init];
			self.picker.canPickVideo = kYTResourceCanPickVideo;
            
			[self.picker showWithSource:sourceType
					fromParentView:nil
							  rect:CGRectZero
					   orBarButton:nil
					   resultBlock:^(UIImage *image)
			{
                
                self.picker = nil;
                
				if(!image)
					return;
				if(sourceType == UIImagePickerControllerSourceTypeCamera)
					[self saveTakenPhotoToCameraRoll:image];
                
                //creates new note
				YTNote *newNote = [[YTNoteManager sharedManager] createNewNote];
                newNote.uniqueIdentifier = [[VLGuid makeUnique] yoditoToString];
                
                //add to notebook
                YTNotebook* notebook = [self notebookForNewNotes];
                newNote.notebook = notebook;
                [notebook addNotesObject: newNote];
                
                //saves the context
                [[DatabaseManager sharedManager] saveContext];
                
				[[VLActivityScreen shared] startActivity];
				YTNoteEditInfo *noteEditInfo = [[YTNoteEditInfo alloc] init];
				[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
				{
					[[VLActivityScreen shared] stopActivity];
					YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
					noteEditView.isNewNote = YES;
					noteEditView.startEditTitleAfterOpen = YES;
					noteEditView.delegate = self;
					[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
					[self pushNewNoteEditView:noteEditView];
					[noteEditView addResourceWithImage:image orVideo:nil resultBlock:^{
					}];
				}];
			}];
		} else {
			YTELCImagePickerController *picker = [[YTELCImagePickerController alloc] init];
            ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
            [picker showWithAssetsLibrary:assetsLibrary ResultBlock:^(NSArray *assets) {
				if([assets count] == 0)
					return;
                
                //creates new note
				YTNote *newNote = [[YTNoteManager sharedManager] createNewNote];
                NSLog(@"new note unique identifier is %@", newNote.uniqueIdentifier);
                newNote.createdDate = [NSDate date];
                
                //add to notebook
                YTNotebook* notebook = [self notebookForNewNotes];
                newNote.notebook = notebook;
                [notebook addNotesObject: newNote];
                
                //saves the context
                [[DatabaseManager sharedManager] saveContext];
				
				[[VLActivityScreen shared] startActivity];
				YTNoteEditInfo *noteEditInfo = [[YTNoteEditInfo alloc] init];
				[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
				{
					[[VLActivityScreen shared] stopActivity];
					YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
					noteEditView.isNewNote = YES;
					noteEditView.startEditTitleAfterOpen = YES;
					noteEditView.delegate = self;
					[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
					[self pushNewNoteEditView:noteEditView];
					[noteEditView addImagesFromAssets:assets];
				}];
			}];
		}
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}

- (void)startAddNewNoteAsPhoto:(BOOL)asPhoto
				 Notebook:(YTNotebook *)notebook
					isStarred:(BOOL)isStarred
		  previousScreenTitle:(NSString *)previousScreenTitle {
    

    if (notebook == nil) {
        notebook = [self notebookForNewNotes];
    }
    
	if(asPhoto) {
        
        NSLog(@"will add as photo");
        
		if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum
							   previousScreenTitle:previousScreenTitle];
			return;
		}
        
        NSLog(@"will add as photo 1");
        
		NSString *actionTake = NSLocalizedString(@"Take Photo", nil);
		NSString *actionChoose = NSLocalizedString(@"Choose From Library", nil);
		NSString *actionCancel = NSLocalizedString(@"Cancel {Button}", nil);
		VLActionSheet *actionSheet = [[VLActionSheet alloc] init];
		[actionSheet addButtonWithTitle:actionTake];
		[actionSheet addButtonWithTitle:actionChoose];
		[actionSheet addButtonWithTitle:actionCancel];
		actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
		[actionSheet showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
			if([NSString isEmpty:btnTitle])
				return;
			if([btnTitle isEqual:actionTake]) {
				[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeCamera
								   previousScreenTitle:previousScreenTitle];
			} else if([btnTitle isEqual:actionChoose]) {
				[self startAddNewNoteAsPhotoWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum
								   previousScreenTitle:previousScreenTitle];
			}
		}];
	} else {
		//NSTimeInterval tm1 = [VLTimer systemUptime];
        
        //creates new note
        YTNote *newNote = [[YTNoteManager sharedManager] createNewNote];
        NSLog(@"new note unique identifier is %@", newNote.uniqueIdentifier);
        newNote.createdDate = [NSDate date];
        
        //add to notebook
        YTNotebook* notebook = [self notebookForNewNotes];
        newNote.notebook = notebook;
        [notebook addNotesObject: newNote];

        if (isStarred) {
            newNote.isFavorite = [NSNumber numberWithBool:YES];
        }
        
        //saves the context
        [[DatabaseManager sharedManager] saveContext];
        		
		[[VLActivityScreen shared] startActivity];
		YTNoteEditInfo *noteEditInfo = [[YTNoteEditInfo alloc] init];
		[noteEditInfo initializeWithNoteOriginal:newNote isNewNote:YES resultBlock:^
		{
			[[VLActivityScreen shared] stopActivity];
			YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
			noteEditView.isNewNote = YES;
			noteEditView.startEditTitleAfterOpen = YES;
			noteEditView.delegate = self;
			[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
			[self pushNewNoteEditView:noteEditView];
		}];
	}
}

- (void)startAddNewNote:(YTNote *)note {
    
    [[VLActivityScreen shared] startActivity];
    YTNoteEditInfo *noteEditInfo = [[YTNoteEditInfo alloc] init];
    [noteEditInfo initializeWithNoteOriginal:note isNewNote:YES resultBlock:^
     {
         [[VLActivityScreen shared] stopActivity];
         YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
         noteEditView.isNewNote = YES;
         noteEditView.startEditTitleAfterOpen = YES;
         noteEditView.delegate = self;
         [noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:@""];
         [self pushNewNoteEditView:noteEditView];
     }];
    
    /*
    YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
    noteEditView.isNewNote = YES;
    noteEditView.startEditTitleAfterOpen = YES;
    noteEditView.delegate = self;
    [noteEditView initializeWithNote:note];
    [self pushNewNoteEditView:noteEditView];
    */
}

- (void)startEditNote:(YTNote *)note previousScreenTitle:(NSString *)previousScreenTitle {
    
	[[VLActivityScreen shared] startActivity];
	YTNoteEditInfo *noteEditInfo = [[YTNoteEditInfo alloc] init];
    
	[noteEditInfo initializeWithNoteOriginal:note isNewNote:NO resultBlock:^
	{
		[[VLActivityScreen shared] stopActivity];
		YTNoteEditView *noteEditView = [[YTNoteEditView alloc] initWithFrame:CGRectZero];
		noteEditView.startEditTitleAfterOpen = YES;
		noteEditView.delegate = self;
		[noteEditView initializeWithNoteEditInfo:noteEditInfo previousScreenTitle:previousScreenTitle];
		[[YTSlidingContainerView shared] showNoteEditView:noteEditView];
	}];
}

- (void)noteEditView:(YTNoteEditView *)noteEditView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDone) {
        //TODO2::::: messengers code commented out until we find if they still are needed
        YTNote *note = noteEditView.noteEditInfo.note;
		//YTNoteInfoArgs *args = [[[YTNoteInfoArgs alloc] init] autorelease];
		//args.note = note;
		[[YTUiMediator shared].msgrNoteAddedManually postMessageWithArgs:note];
	}
    
	[[YTSlidingContainerView shared] closeNoteEditView:noteEditView];
}

- (void)showNoteView:(YTNoteView *)noteView
	optionalFromCellView:(YTNoteTableCellView *)noteCellView
	optionalOnThumbsView:(YTPhotosThumbsView *)thumbsView
	optionalFromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView {
	
	YTNote *note = noteView.note;
	// Opening note:
    
    NSArray* imagesToShowInList = [[YTAttachmentManager sharedManager] getAttachmentsFromNote: note OfType:YT_ATTACH_TYPE_PHOTO];

	BOOL needWaitForShowImage = (imagesToShowInList.count == 1);
	NSTimeInterval uptimeStart = [VLTimer systemUptime];
	__block BOOL activityShown = NO;
	NSTimeInterval delayBeforeShowActivity = 0.5;
	NSTimeInterval maxWaitFroShowImage = 2.0;
	
	[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
		NSTimeInterval uptime = [VLTimer systemUptime];
		if([noteView isNoteLoaded]) {
			if(needWaitForShowImage) {
				if([noteView isAllImagesShown])
					return YES;
				if(uptime >= (uptimeStart + maxWaitFroShowImage))
					return YES;
			} else
				return YES;
		}
		if(!activityShown && uptime >= (uptimeStart + delayBeforeShowActivity)) {
			[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Opening", nil)];
			activityShown = YES;
		}
		return NO;
	} ignoringTouches:YES completeBlock:^{
		// Wait a little, let new view be drawn:
		[[VLMessageCenter shared] performBlock:^{
			if(activityShown)
				[[VLActivityScreen shared] stopActivity];
			
			if(noteCellView) {
				[[YTSlidingContainerView shared] showNoteView:noteView fromCellView:noteCellView];
			} else if(thumbsView && thumbView) {
				[[YTSlidingContainerView shared] showNoteView:noteView fromThumbView:thumbView];
			}
		}
		 afterDelay:kDefaultAnimationDuration/4 ignoringTouches:YES];
	}];
}

- (void)saveTakenPhotoToCameraRoll:(UIImage *)image {
	if(!image)
		return;
	if(![YTSettingsManager shared].saveTakenPhotosToCameraRoll)
		return;
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	if(error)
		VLLoggerError(@"%@", error);
}

- (void)beginIsScrolling {
	_isScrollingCounter++;
	if(_isScrollingCounter == 1) {
		//VLLoggerTrace(@"");
		[_msgrScrollingEnded cancelPostMessage];
	}
}

- (void)endIsScrolling {
	if(_isScrollingCounter > 0) {
		_isScrollingCounter--;
		if(_isScrollingCounter == 0) {
			//VLLoggerTrace(@"");
			[_msgrScrollingEnded postMessage];
		}
	}
}

- (BOOL)isScrolling {
	return (_isScrollingCounter > 0);
}


@end

