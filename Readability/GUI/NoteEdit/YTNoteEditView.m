
#import "YTNoteEditView.h"
#import "../Main/Classes.h"
#import "../Notes/Classes.h"
#import "../YTUiMediator.h"

#define kTagsPullRatio 0.5
#define kTextOffsetX 14.0
#define kActivityYOffset (-60)
#define kDelayBeginEditTagAfterPull (kDefaultAnimationDuration*2)
#define kMinAutoSavingInterval 0.5
#define kTagsSeparBottomOffsetX 14.0


@implementation YTNoteEditView_PlaceholderView

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		self.backgroundColor = [UIColor clearColor];
		self.textColor = [UIColor lightGrayColor];
		self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		self.textAlignment = NSTextAlignmentLeft;
		self.text = [YTNote titlePlaceholder];
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

- (CGSize)sizeThatFits:(CGSize)size {
	return [self.text vlSizeWithFont:self.font];
}

- (void)removeFromSuperview {
//    NSLog(@"YTNoteEditView_PlaceholderView::removeFromSuperview");
    [super removeFromSuperview];
}

- (void) dealloc {
//    NSLog(@"YTNoteEditView_PlaceholderView::dealloc");
}

@end


@implementation YTNoteEditView

@synthesize delegate = _delegate;
@synthesize startEditTitleAfterOpen = _startEditTitleAfterOpen;
@synthesize isNewNote = _isNewNote;

- (void)initialize {
    NSLog(@"YTNoteEditView::initialize");
    
	[super initialize];
	self.backgroundColor = kYTViewBackColor;//[UIColor whiteColor];
	
	_tvContent = [[UITextView alloc] initWithFrame:CGRectZero];
	_tvContent.delegate = self;
	_tvContent.backgroundColor = self.backgroundColor;
	_tvContent.textColor = kYTNoteTitleColor;
	_tvContent.alwaysBounceVertical = YES;
	_tvContent.clipsToBounds = NO;
	if([_tvContent respondsToSelector:@selector(setTintColor:)])
		_tvContent.tintColor = [UIColor colorWithRed:0x5E/255.0 green:0x7D/255.0 blue:0x9A/255.0 alpha:1.0];
	[self addSubview:_tvContent];
	if(kIosVersionFloat >= 7.0) {
		NSLayoutManager *layoutManr = _tvContent.layoutManager;
		layoutManr.delegate = self;
	}
	
	//_tvPlaceholder = [[YTNoteEditView_PlaceholderView alloc] initWithFrame:CGRectZero];
	//_tvPlaceholder.hidden = YES;
	//[_tvContent addSubview:_tvPlaceholder];
	
	_lastText = @"";
	
	_itemsView = [[YTNoteEditItemsView alloc] initWithFrame:CGRectZero];
	_itemsView.delegate = self;
	_itemsView.backgroundColor = self.backgroundColor;
	[self addSubview:_itemsView];
	
	_tagsLineView = [[YTTagsLineView alloc] initWithFrame:CGRectZero];
	_tagsLineView.delegate = self;
	_tagsLineView.allowEditing = YES;
	[_tagsLineView.buttonAdd addTarget:self action:@selector(onBtnAddTagTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_tagsLineView];
	
	_sepTagsBot = [[YTNoteContentSeparator alloc] initWithFrame:CGRectZero];
	_sepTagsBot.style = EYTNoteContentSeparatorStyleOneLine;
	[self addSubview:_sepTagsBot];
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 0.05;
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_timer.enabledAlwaysFiring = YES;
	[_timer start];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
		[_tvContent becomeFirstResponder];
	});
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameBeginUserInfoKey:) name:UIKeyboardFrameBeginUserInfoKey object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameEndUserInfoKey:) name:UIKeyboardFrameEndUserInfoKey object:nil];
	
    //observe changes on note
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object: [DatabaseManager sharedManager].managedObjectContext];
    
    
	[self suspendSliding:YES];
    
    NSLog(@"YTNoteEditView::initialize end");
}

//we received a change object
- (void) handleDataModelChange: (NSNotification*) notification {
    //lets see if its our note
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    if ([updatedObjects count] > 0) {
        NSLog(@"has updated objects [on YTNoteEditView]");
        
        //lets see if our note is within the updated objects
        for(NSManagedObject* obj in updatedObjects) {
            if ([obj isEqual: self.noteEditInfo.note]) {
                NSLog(@"yes, is our note [we are on YTNoteEditView]");
                
                //make sure we've the most updated tags count
                if ([self.noteEditInfo.note.tags count] > 0) {
                    _itemsView.buttonTag.badgeText = [NSString stringWithFormat:@"%d", (int) [self.noteEditInfo.note.tags count]];
                }
                else {
                    _itemsView.buttonTag.badgeText = @"";
                }

                [_itemsView enableButtonWithType:EYTNoteEditButtonTypeTag enable:([self.noteEditInfo.note.tags count] > 0)];
                
                //make sure we've the most updated attachments count
                if ([self.noteEditInfo.note.attachments count] > 0) {
                    _itemsView.buttonCamera.badgeText = [NSString stringWithFormat:@"%d", (int) [self.noteEditInfo.note.attachments count]];
                }
                else {
                    _itemsView.buttonCamera.badgeText = @"";
                }
                
                [_itemsView enableButtonWithType:EYTNoteEditButtonTypeCamera enable:[self.noteEditInfo.note.attachments count] > 0];
                
                break;
            }
        }
    }
}

- (void)updateFonts:(id)sender {
	_tvContent.font = [[YTFontsManager shared] fontWithSize:16];
	if(_tvPlaceholder)
		_tvPlaceholder.font = _tvContent.font;
	[self setNeedsLayout];
}

- (void)initializeWithNoteEditInfo:(YTNoteEditInfo *)noteEditInfo previousScreenTitle:(NSString *)previousScreenTitle {
    NSLog(@"YTNoteEditView::initializeWithNoteEditInfo");
    
	self.noteEditInfo = noteEditInfo;
    
    YTNote* note = noteEditInfo.note;
    
    self.note = note;
    
	NSString *sNoteContent = note.content;
    
	_isNoteContentHtml = [[YTNoteHtmlParser shared] isNoteTextHtml:sNoteContent];
	if(_isNoteContentHtml) {
		_tvContent.text = note.content;
	} else {
		NSString *content = sNoteContent;
		NSString *content1 = content;
		if(!content1)
			content1 = @"";
        
		NSString *content2 = [[YTNoteHtmlParser shared] correctHtmlText:content1];
		_tvContent.text = content2;
		_tvContent.userInteractionEnabled = YES;
	}
    
	if(_tvContent.text.length > 100) {
		//_tvContent.selectedRange = NSMakeRange(0, 0);
		//[[VLMessageCenter shared] performBlock:^{
		//	_tvContent.selectedRange = NSMakeRange(_tvContent.text.length, 0);
		//} afterDelay:0.001 ignoringTouches:YES];
	}
	_lastText = [_tvContent.text copy];
    
	if(_tvPlaceholder)
		_tvPlaceholder.hidden = ![NSString isEmpty:_lastText];
	
	_itemsView.note = self.note;
	_itemsView.noteEditInfo = self.noteEditInfo;
	_tagsLineView.noteEditInfo = self.noteEditInfo;
	
	//self.customNavBar.titleLabel.textColor = kYTNoteTitleColor;
    
	NSDate *createdDate = self.noteEditInfo.note.createdDate;
	NSDateFormatter *frm = [[NSDateFormatter alloc] init];
	frm.timeStyle = NSDateFormatterNoStyle;
	frm.dateStyle = NSDateFormatterMediumStyle;
	self.customNavBar.titleLabel.text = [frm stringFromDate:createdDate];
	
	self.customNavBar.btnBack.hidden = NO;
	self.customNavBar.btnRight.hidden = NO;
	//if(![NSString isEmpty:previousScreenTitle])
	//	[self.customNavBar.btnBack setTitle:previousScreenTitle forState:UIControlStateNormal];
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Done {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnDoneTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	_lastAutoSavedDataVersion = self.noteEditInfo.version;
	
	[self updateViewAsync];
    
}

- (void)initializeWithNote:(YTNote *)note {
    NSLog(@"YTNoteEditView::initializeWithNote");
    
	//self.noteEditInfo = noteEditInfo;
		  
    _tvContent.text = [[YTNoteHtmlParser shared] correctHtmlText:note.content];
    _tvContent.userInteractionEnabled = YES;
	
	_lastText = [_tvContent.text copy];
	if(_tvPlaceholder)
		_tvPlaceholder.hidden = ![NSString isEmpty:_lastText];
	
	_itemsView.note = self.note;
	_itemsView.noteEditInfo = self.noteEditInfo;
	_tagsLineView.noteEditInfo = self.noteEditInfo;
	
	NSDate *createdDate = note.createdDate;
	NSDateFormatter *frm = [[NSDateFormatter alloc] init];
	frm.timeStyle = NSDateFormatterNoStyle;
	frm.dateStyle = NSDateFormatterMediumStyle;
	self.customNavBar.titleLabel.text = [frm stringFromDate:createdDate];
	
	self.customNavBar.btnBack.hidden = NO;
	self.customNavBar.btnRight.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Done {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnDoneTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	_lastAutoSavedDataVersion = self.noteEditInfo.version;
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	//NSTimeInterval tm1 = [VLTimer systemUptime];
	//YTApiMediator *apiMedr = [YTApiMediator shared];
	
	YTNoteEditInfo *noteEditInfo = self.noteEditInfo;
	YTNote *note = noteEditInfo.note;
	int attachsCount = 0;
	NSArray *resources = [self.noteEditInfo.note.attachments allObjects];
	for(YTAttachment *info in resources) {
		if(([info isImage] || kYTAllowOpenNonImageResources)/* && !info.isThumbnail*/)
			attachsCount++;
	}

	[_itemsView showButtonWithType:EYTNoteEditButtonTypeTag show:YES];
	[_itemsView enableButtonWithType:EYTNoteEditButtonTypeTag enable:([noteEditInfo.note.tags count] > 0)];
	[_itemsView showButtonWithType:EYTNoteEditButtonTypeLocation show:YES];
	[_itemsView enableButtonWithType:EYTNoteEditButtonTypeLocation enable:(noteEditInfo.note.location != nil)];
	[_itemsView showButtonWithType:EYTNoteEditButtonTypeCamera show:YES];
	[_itemsView enableButtonWithType:EYTNoteEditButtonTypeCamera enable:(attachsCount > 0)];
	[_itemsView showButtonWithType:EYTNoteEditButtonTypeStarred show:YES];
    [_itemsView enableButtonWithType:EYTNoteEditButtonTypeStarred enable: [note.isFavorite boolValue]];
    
	[_itemsView showButtonWithType:EYTNoteEditButtonTypeBook show:YES];
	[_itemsView enableButtonWithType:EYTNoteEditButtonTypeBook enable:![note.notebook.uniqueIdentifier isEqualToString:[[YTNotebookManager sharedManager] getDefaultNotebook].uniqueIdentifier]];
	
	if([noteEditInfo.note.tags count] > 0)
		_itemsView.buttonTag.badgeText = [NSString stringWithFormat:@"%d", (int) [noteEditInfo.note.tags count]];
	else
		_itemsView.buttonTag.badgeText = @"";
	if(attachsCount > 0)
		_itemsView.buttonCamera.badgeText = [NSString stringWithFormat:@"%d", attachsCount];
	else
		_itemsView.buttonCamera.badgeText = @"";
	
	YTSettingsManager *manrSett = [YTSettingsManager shared];
	if(!_triedGetCurLocation && manrSett.autoAddNoteLocation) {
		_triedGetCurLocation = YES;
		if(_isNewNote) {
			_tryGetCurLocTicket++;
			int tryGetCurLocTicket = _tryGetCurLocTicket;
			_gettingCurrentLocationCounter++;
			//[self showGettingCurLocationActivity:_gettingCurrentLocationCounter > 0];
			[YTMapSearchView getAddressFromCurrentLocationWithResultBlock:^(YTLocation *resultLocation, NSError *error) {
				if(tryGetCurLocTicket != _tryGetCurLocTicket || !resultLocation || error) {
					_gettingCurrentLocationCounter--;
					//[self showGettingCurLocationActivity:_gettingCurrentLocationCounter > 0];
					return;
				}
				[YTMapSearchView getAddressFromCurrentLocationWithResultBlock:^(YTLocation *resultLocation, NSError *error) {
					_gettingCurrentLocationCounter--;
					//[self showGettingCurLocationActivity:_gettingCurrentLocationCounter > 0];
					if(tryGetCurLocTicket != _tryGetCurLocTicket)
						return;
					if(!resultLocation || error)
						return;
					if(self.noteEditInfo.note.location)
						return;
					if(!self.window)
						return;
					UIView *view = self;
					while(view) {
						if(view.hidden)
							return;
						view = view.superview;
					}
					self.noteEditInfo.note.location = resultLocation;
				}];
			}];
		}
	}
	//NSTimeInterval tm2 = [VLTimer systemUptime];
	//VLLogEvent(([NSString stringWithFormat:@"%0.4f s", tm2 - tm1]));
}

- (void)showGettingCurLocationActivity:(BOOL)show {
	if(_showingGettingCurLocActivity != show) {
		_showingGettingCurLocActivity = show;
		if(_showingGettingCurLocActivity) {
			if(!_isNewNote && !_overlayGettingCurLoc) {
				UIWindow *wnd = [UIApplication sharedApplication].keyWindow;
				float maxSide = MAX(wnd.frame.size.width, wnd.frame.size.height);
				_overlayGettingCurLoc = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maxSide, maxSide)];
				_overlayGettingCurLoc.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.01];
				[wnd addSubview:_overlayGettingCurLoc];
			}
			if(!_activityGettingCurLoc) {
				_activityGettingCurLoc = [[YTActivityView alloc] initWithFrame:CGRectZero];
				[[VLAppDelegateBase sharedAppDelegateBase].rootViewController.view addSubview:_activityGettingCurLoc];
				[self layoutSubviews];
				_activityGettingCurLoc.title = NSLocalizedString(@"Getting current location", nil);
				_activityGettingCurLoc.yOffset = kActivityYOffset;
				_activityGettingCurLoc.dimBackground = NO;
				[_activityGettingCurLoc startActivity];
			}
		} else {
			if(_overlayGettingCurLoc) {
				[_overlayGettingCurLoc removeFromSuperview];
				_overlayGettingCurLoc = nil;
			}
			if(_activityGettingCurLoc) {
				[_activityGettingCurLoc stopActivity];
				[_activityGettingCurLoc removeFromSuperview];
				_activityGettingCurLoc = nil;
			}
		}
	}
}

- (void)showActivitySaveImages:(BOOL)show {
	if(show) {
		if(!_activitySaveImages) {
			_activitySaveImages = [[YTActivityView alloc] initWithFrame:CGRectZero];
			_activitySaveImages.title = NSLocalizedString(@"Saving", nil);
			_activitySaveImages.yOffset = kActivityYOffset;
			if(_imagesToSave > 1)
				_activitySaveImages.progressMode = VLProgressHUDModeDeterminate;
			[[VLAppDelegateBase sharedAppDelegateBase].rootViewController.view addSubview:_activitySaveImages];
			[self layoutSubviews];
			[_activitySaveImages startActivity];
		}
		if(_imagesToSave > 1) {
			_activitySaveImages.progress = (_imagesToSave - _imagesToSaveLeft) / (float)_imagesToSave;
		}
	} else {
		if(_activitySaveImages) {
			[_activitySaveImages stopActivity];
			[_activitySaveImages removeFromSuperview];
			_activitySaveImages = nil;
		}
	}
}

- (float)allTagsHeight {
	float result = 0;
	CGSize size = CGSizeMake(100, 100);
	result += [_tagsLineView sizeThatFits:size].height;
	result += [_sepTagsBot sizeThatFits:size].height;
	return result;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if(_activityGettingCurLoc && _activityGettingCurLoc.superview)
		_activityGettingCurLoc.frame = _activityGettingCurLoc.superview.bounds;
	CGRect rcBnds = self.boundsNoBars;
	int border = 0;
	CGRect rcCtrls = CGRectInset(rcBnds, border, border);
	
	CGRect rcTags = rcCtrls;
	rcTags.origin.x = rcBnds.origin.x;
	rcTags.size.width = rcBnds.size.width;
	rcTags.origin.y = rcBnds.origin.y;
	rcTags.size.height = [_tagsLineView sizeThatFits:rcTags.size].height;
	
	CGRect rcSepTagsBot = rcCtrls;
	rcSepTagsBot.size.height = [_sepTagsBot sizeThatFits:rcSepTagsBot.size].height;
	rcSepTagsBot.origin.y = CGRectGetMaxY(rcTags);
	rcSepTagsBot.origin.x += kTagsSeparBottomOffsetX;
	rcSepTagsBot.size.width -= kTagsSeparBottomOffsetX * 2;
	
	CGRect rcContent = rcCtrls;
	//float distY = 4.0;
	//rcContent.origin.y = CGRectGetMaxY(rcSepTagsBot) + distY;
	rcContent.origin.x += kTextOffsetX;
	rcContent.size.width -= kTextOffsetX * 2;
	rcContent.size.height = CGRectGetMaxY(rcCtrls) - rcContent.origin.y;
	
	CGPoint contentOffset =  _tvContent.contentOffset;
	
	float allTagsHeight = [self allTagsHeight];
	rcTags.origin.y = rcTags.origin.y - allTagsHeight - contentOffset.y;
	rcSepTagsBot.origin.y = rcSepTagsBot.origin.y - allTagsHeight - contentOffset.y;
	if(_tagsShown) {
		rcTags.origin.y += allTagsHeight;
		rcSepTagsBot.origin.y += allTagsHeight;
		rcContent.origin.y += allTagsHeight;
		rcContent.size.height -= allTagsHeight;
	}
	
	CGRect rcItemsView = rcBnds;
	rcItemsView.size.height = [_itemsView sizeThatFits:rcItemsView.size].height;
	rcItemsView.origin.y = CGRectGetMaxY(rcBnds) - rcItemsView.size.height;
	if(_keyboardShown) {
		CGRect rcKeyb = [self sharedRectWithKeyboard];
		rcItemsView.origin.y = rcKeyb.origin.y - rcItemsView.size.height;
	}
	rcContent.size.height = rcItemsView.origin.y - rcContent.origin.y;
	
	_tagsLineView.frame = [UIScreen roundRect:rcTags];
	_sepTagsBot.frame = [UIScreen roundRect:rcSepTagsBot];
	rcContent = [UIScreen roundRect:rcContent];
	if(!CGRectEqualToRect(_tvContent.frame, rcContent)) {
		_tvContent.frame = rcContent;
		if(_tvPlaceholder) {
			CGRect rcPH = _tvContent.bounds;
			rcPH.size = [_tvPlaceholder sizeThatFits:rcPH.size];
			if([_tvContent respondsToSelector:@selector(textContainerInset)]) {
				UIEdgeInsets textContainerInset = _tvContent.textContainerInset;
				rcPH.origin.x += textContainerInset.left;
				rcPH.origin.y += textContainerInset.top;
			}
			rcPH.origin.x += 6.0;
			_tvPlaceholder.frame = rcPH;
		}
	}
	_itemsView.frame = [UIScreen roundRect:rcItemsView];
	if(_activitySaveImages && _activitySaveImages.superview) {
		UIView *sv = _activitySaveImages.superview;
		[sv bringSubviewToFront:_activitySaveImages];
		CGRect rc = sv.bounds;
		_activitySaveImages.frame = rc;
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGPoint contentOffset =  _tvContent.contentOffset;
	//NSLog(@"%f", contentOffset.y);
	[self setNeedsLayout];
	if(_animatingShowingTags)
		return;
	_isScrollingNEV = YES;
	float allTagsHeight = [self allTagsHeight];
	if(!_tagsShown && contentOffset.y < 0 && (-contentOffset.y) > allTagsHeight*kTagsPullRatio) {
		[self showTags:YES];
		[[VLMessageCenter shared] performBlock:^{
			if(_tagsShown)
				[_tagsLineView startEditNewTag];
		} afterDelay:kDelayBeginEditTagAfterPull ignoringTouches:NO];
	} else if(_tagsShown && contentOffset.y > 0 && contentOffset.y > allTagsHeight*kTagsPullRatio) {
		[self showTags:NO];
	}
	_isScrollingNEV = NO;
}

- (void)showTags:(BOOL)show {
	if(_tagsShown != show) {
		_animatingShowingTags = YES;
		UITextAutocorrectionType lastTextAutocorrectionType = _tvContent.autocorrectionType;
		if(!show) {
			[_tagsLineView stopEditingTag];
			//if(![_tvContent isFirstResponder])
			//	[_tvContent becomeFirstResponder];
			_tvContent.autocorrectionType = UITextAutocorrectionTypeNo;
			NSRange selRange = _tvContent.selectedRange;
			if(selRange.length)
				_tvContent.selectedRange = NSMakeRange(selRange.location, 0);
		}
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_tagsShown = show;
			if(_isScrollingNEV) {
				CGPoint contentOffset =  _tvContent.contentOffset;
				float allTagsHeight = [self allTagsHeight];
				if(_tagsShown)
					contentOffset.y += allTagsHeight/2;
				else
					contentOffset.y -= allTagsHeight * (1 - kTagsPullRatio);
				_tvContent.contentOffset = contentOffset;
				//[self setNeedsLayout];
				[self layoutSubviews];
			} else {
				[self layoutSubviews];
			}
		} completion:^(BOOL finished) {
			if(finished) {
				_animatingShowingTags = NO;
				_tvContent.autocorrectionType = lastTextAutocorrectionType;
			}
		}];
	}
}

- (void)onBecomeTopAgainInNavigation {
	[super onBecomeTopAgainInNavigation];
	/*UIView *firstResp = [VLCtrlsUtils findFirstResponder:self];
	if(!firstResp) {
		firstResp = _lastFirstResponderRef;
		if(!firstResp)
			firstResp = _tvContent;
		[firstResp becomeFirstResponder];
	}*/
}

- (void)onNoteEditInfoDataChanged {
	[super onNoteEditInfoDataChanged];
	[self updateViewAsync];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if(_overlayGettingCurLoc)
		return NO;
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
	_lastFirstResponderRef = textView;
	if(textView == _tvContent) {
		[[VLMessageCenter shared] performBlock:^{
			if([_tvContent isFirstResponder] && !_tagsLineView.popupMenuShown)
				[self showTags:NO];
		//} afterDelay:kDefaultAnimationDuration*2 ignoringTouches:NO];
		} afterDelay:0.001 ignoringTouches:NO];
	}
}

- (void)textViewDidChange:(UITextView *)textView {
	if(kIosVersionFloat >= 7.0) { // Kludge
		NSString *newText = _tvContent.text;
		if(newText.length == _lastText.length + 1) {
			if([newText characterAtIndex:newText.length - 1] == '\n') {
				UIFont *font = _tvContent.font;
				float lineHeight = [@"A" vlSizeWithFont:font].height;
				CGSize contentSize = _tvContent.contentSize;
				CGPoint contentOffset = _tvContent.contentOffset;
				CGRect rcBnds = _tvContent.frame;
				CGSize szFit = [_tvContent sizeThatFits:CGSizeMake(rcBnds.size.width, 10000)];
				if(contentSize.height < szFit.height && szFit.height > rcBnds.size.height) {
					CGSize contentSizeNew = contentSize;
					contentSizeNew.height = szFit.height;
					CGPoint contentOffsetNew = contentOffset;
					contentOffsetNew.y = contentSizeNew.height - rcBnds.size.height;
					contentOffsetNew.y -= (int)(lineHeight * 0.35);
					[_tvContent setContentSize:contentSizeNew];
					[_tvContent setContentOffset:contentOffsetNew animated:NO];
				}
			}
		}
		_lastText = [newText copy];
		if(_tvPlaceholder)
			_tvPlaceholder.hidden = ![NSString isEmpty:_lastText];
	}
	[self.noteEditInfo modifyVersion];
}

- (void)closeWithAction:(EYTUserActionType)action {
    NSLog(@"YTNoteEditView::closeWithAction");
    
	if(_isAutoSaving) {
        
        NSLog(@"is autosaving");
        
		[[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Saving", nil) yOffset:kActivityYOffset];
		[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
			return !_isAutoSaving;
		} ignoringTouches:NO completeBlock:^{
			[VLCtrlsUtils findAndResignFirstResponder:self];
			[[VLActivityScreen shared] stopActivity];
			[self suspendSliding:NO];
			if(_delegate)
				[_delegate noteEditView:self finishWithAction:EYTUserActionTypeCancel];
			else
				[[YTSlidingContainerView shared] closeNoteEditView:self];
		}];
		return;
	}
    else {
        NSLog(@"is not autosaving");
    }
    
	[self suspendSliding:NO];
	if(action == EYTUserActionTypeCancel && _isNewNote) {
        
        [[DatabaseManager sharedManager].managedObjectContext deleteObject: self.note];
        
		[VLCtrlsUtils findAndResignFirstResponder:self];
		if(_delegate)
			[_delegate noteEditView:self finishWithAction:EYTUserActionTypeCancel];
		else
			[[YTSlidingContainerView shared] closeNoteEditView:self];
		return;
	}
    
	[VLCtrlsUtils findAndResignFirstResponder:self];
    
	if(action == EYTUserActionTypeDone || kYTAutoSaveEditedNote) {
        
		[self applyChangesToNoteWithDoneEditing:YES resultBlock:^{
			if(_delegate)
				[_delegate noteEditView:self finishWithAction:EYTUserActionTypeDone];
			else
				[[YTSlidingContainerView shared] closeNoteEditView:self];
		}];
	} else {
		if(_delegate)
			[_delegate noteEditView:self finishWithAction:EYTUserActionTypeDone];
		else
			[[YTSlidingContainerView shared] closeNoteEditView:self];
	}
}

- (void)onBtnCancelTap:(id)sender {
	[self closeWithAction:EYTUserActionTypeCancel];
}

- (void)onBtnDoneTap:(id)sender {
    NSLog(@"onBtnDoneTap");
//    NSLog(@"note is %@", self.note);
//    NSLog(@"note[2] is %@", self.noteEditInfo.note);
    
	[self closeWithAction:EYTUserActionTypeDone];
}

- (BOOL)checkViewIsCovered:(UIView *)superview curView:(UIView *)curView {
	if(!superview || !curView)
		return NO;
	CGRect rcAppFrame = [UIScreen mainScreen].applicationFrame;
	BOOL isOver = NO;
	for(UIView *view in superview.subviews) {
		if(view.hidden)
			continue;
		if(view == curView) {
			isOver = YES;
			continue;
		}
		if(!isOver)
			continue;
		CGRect rcViewWnd = [view convertRect:view.bounds toView:nil];
		if(!CGRectIntersectsRect(rcAppFrame, rcViewWnd))
			continue;
		CGRect rcView = [view convertRect:view.bounds toView:curView];
		if(CGRectIntersectsRect(rcView, curView.bounds))
			return YES;
		UIView *curSuperview = view;
		if([self checkViewIsCovered:curSuperview.superview curView:curSuperview])
			return YES;
	}
	return NO;
}

- (BOOL)checkViewVisible:(UIView *)view {
	if(view.hidden || !view.window)
		return NO;
	UIView *superview = view.superview;
	while(superview) {
		if(superview.hidden)
			return NO;
		superview = superview.superview;
	}
	UIWindow *window = [UIApplication sharedApplication].keyWindow;
	CGRect rcAppFrame = [UIScreen mainScreen].applicationFrame;
	CGRect rcView = [view convertRect:view.bounds toView:window];
	if(!CGRectIntersectsRect(rcAppFrame, rcView))
		return NO;
	return YES;
}

- (void)onTimerEvent:(id)sender {
	// Check if view is on top and becode first responder
	BOOL isPickerShown = [YTImagePickerController isShown] || [YTELCImagePickerController isShown] || [YTActionSheet isShown]
		|| (_pickerShownCounter > 0);
	if(![_tvContent isFirstResponder] && [self checkViewVisible:self] && self.alpha == 1.0 && !isPickerShown
	   && !_overlayGettingCurLoc) {
		if(![self checkViewIsCovered:self.superview curView:self]) {
			if(![VLCtrlsUtils findFirstResponder:_tagsLineView]) {
				//VLActivityView *activView = (VLActivityView *)[VLCtrlsUtils getSubViewOfClass:[VLActivityView class]
				//						parentView:[UIApplication sharedApplication].keyWindow];
				//if(!activView) {
					[_tvContent becomeFirstResponder];
				//}
			}
		}
	}
	if([_tvContent isFirstResponder]) {
		if(!_wasFirstResponder) {
			_wasFirstResponder = YES;
			[self setNeedsLayout];
		}
	} else {
		_wasFirstResponder = NO;
	}
	if(_overlayGettingCurLoc) {
		//if([_tvContent isFirstResponder])
		//	[_tvContent resignFirstResponder];
		if(_overlayGettingCurLoc.superview != [UIApplication sharedApplication].keyWindow) {
			if(_overlayGettingCurLoc.superview)
				[_overlayGettingCurLoc removeFromSuperview];
			[[UIApplication sharedApplication].keyWindow addSubview:_overlayGettingCurLoc];
		}
		[_overlayGettingCurLoc.superview bringSubviewToFront:_overlayGettingCurLoc];
	}
	YTNoteEditInfo *noteEditInfo = self.noteEditInfo;
	if(kYTAutoSaveEditedNote) {
		BOOL canAutoSave = !_isNewNote || _newNoteNeedsAutosave;
		if(_isNewNote) {
			if([noteEditInfo.note.attachments count] > 0 || [noteEditInfo.note.tags count] > 0
			   || [_tvContent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
				_newNoteNeedsAutosave = YES;
				canAutoSave = YES;
			}
		}
		if(_imagesToSaveLeft)
			canAutoSave = NO;
		if(canAutoSave && _lastAutoSavedDataVersion != self.noteEditInfo.version) {
			NSTimeInterval uptime = [VLTimer systemUptime];
			if(!_isAutoSaving && uptime >= (_lastAutosavedUptime + kMinAutoSavingInterval)) {
				_isAutoSaving = YES;
				[self applyChangesToNoteWithDoneEditing:NO resultBlock:^{
					_lastAutoSavedDataVersion = self.noteEditInfo.version;
				}];
			}
		}
	}
}

- (void)applyChangesToNoteWithDoneEditing:(BOOL)doneEditing resultBlock:(VLBlockVoid)resultBlock {
    NSLog(@"applyChangesToNoteWithDoneEditing: %d", doneEditing);
    
//    NSLog(@"editinfo is %@", self.noteEditInfo);
//    NSLog(@"self is %@", self);
    
	BOOL isAutoSaving = _isAutoSaving;
	VLLoggerTrace(@"");
	// Update Tags:
	YTNoteEditInfo *editInfo = self.noteEditInfo;
	YTNote *note = editInfo.note;
    
	if(_tvContent.userInteractionEnabled) {
		if(_isNoteContentHtml)
			note.content = _tvContent.text;
		else {
			NSString *newContent = _tvContent.text;
			note.content = newContent;
            
            /*
			int wordsCount = 0;
			int charsCount = 0;
			note.contentLimited = [YTNoteInfo getContentLimitedWithContent:newContent wordsCount:&wordsCount charsCount:&charsCount];
			note.words = wordsCount;
			note.characters = charsCount;
            */
		}
	}

    if(!isAutoSaving)
        [[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Saving", nil) yOffset:kActivityYOffset];

    note.updatedDate = [NSDate date];
    [note fillUpdatedDateTimezone];
    
    //TODO:::check if we need to applyChanges only if autosaving
    //or only with done editing
    if (doneEditing) {
        [editInfo applyChanges];
    }
    
    [[VLActivityScreen shared] stopActivity];
    
    if(isAutoSaving) {
        _isAutoSaving = NO;
        _lastAutosavedUptime = [VLTimer systemUptime];
    }
    
    resultBlock();
}

#pragma mark - Keyboard notifications

- (void)procesKeyboardEvent:(id)obj {
	if(!obj || ![obj isKindOfClass:[NSNotification class]])
		return;
	NSNotification *notify = (NSNotification*)obj;
	CGRect keybBounds;
	id idVal = [notify.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
	if(!idVal || ![idVal isKindOfClass:[NSValue class]])
		return;
	NSValue *val = (NSValue*)idVal;
	[val getValue: &keybBounds];
	_frameOfKeyboard = keybBounds;
}

- (void)keyboardWillShow:(id)obj {
	_keyboardShown = YES;
	[self procesKeyboardEvent:obj];
	[self layoutSubviews];
}

- (void)keyboardDidShow:(id)obj {
	[self procesKeyboardEvent:obj];
}

- (void)keyboardWillHide:(id)obj {
	_keyboardShown = NO;
	[self procesKeyboardEvent:obj];
	[self layoutSubviews];
}

- (void)keyboardDidHide:(id)obj {
	[self procesKeyboardEvent:obj];
}

- (void)keyboardFrameBeginUserInfoKey:(id)obj {
	[self procesKeyboardEvent:obj];
}

- (void)keyboardFrameEndUserInfoKey:(id)obj {
	[self procesKeyboardEvent:obj];
}

- (CGRect)sharedRectWithKeyboard {
	CGRect rcBnds = [self convertRect:self.bounds toView:nil];
	CGRect rcKeyboard = _frameOfKeyboard;
	if(!_keyboardShown || !CGRectIntersectsRect(rcBnds, rcKeyboard))
		return CGRectMake(rcBnds.origin.x, CGRectGetMaxY(rcBnds), rcBnds.size.width, 0);
	CGRect rcShared = CGRectIntersection(rcBnds, rcKeyboard);
	rcShared = [self convertRect:rcShared fromView:nil];
	return rcShared;
}

- (void)takePhoto {
	if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[VLAlertView showWithOkAndTitle:NSLocalizedString(@"Error {Title}", nil) message:NSLocalizedString(@"Device does not support camera functionality", nil)];
		return;
	}
    
    NSLog(@"takePhoto tapped");
    
	[VLCtrlsUtils findAndResignFirstResponder:self];
	_pickerShownCounter++;
	[[VLMessageCenter shared] performBlock:^{
		_pickerShownCounter--;
		YTImagePickerController *picker = [[YTImagePickerController alloc] init];
		picker.canPickVideo = kYTResourceCanPickVideo;
		[picker showWithSource:UIImagePickerControllerSourceTypeCamera
				fromParentView:nil
						  rect:CGRectZero
				   orBarButton:nil
				   resultBlock:^(UIImage *image)
		{
            NSLog(@"returned with image");

            
            @autoreleasepool {
                [[YTUiMediator shared] saveTakenPhotoToCameraRoll:image];
            }
            
            @autoreleasepool {
                [self addResourceWithImage:image orVideo:picker.pathToChosenVideo resultBlock:^{
                }];
            }
		}];
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}

- (void)choosePhoto {
    NSLog(@"choosePhoto");
    
	if(kYTUseMultiselectImagePicker) {
		[VLCtrlsUtils findAndResignFirstResponder:self];

		YTELCImagePickerController *picker = [[YTELCImagePickerController alloc] init];
        
        //create assets library and pass it to the picker
        //the reason we're doing it here is because ALAssets
        //can be used after the lifetime of its parent ALAssetsLibrary
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [picker showWithAssetsLibrary:self.assetsLibrary ResultBlock:^(NSArray *assets) {
            
			if([assets count] > 0) {
				[[VLMessageCenter shared] performBlock:^{
					if(!_savingImagesStarted) {
						_savingImagesStarted = YES;
						_imagesToSave = _imagesToSaveLeft = (int)[assets count];
						[self showActivitySaveImages:YES];
					}
					[self performSelector:@selector(addImagesFromAssets:) withObject:assets afterDelay:kDefaultAnimationDuration/2];
				} afterDelay:kDefaultAnimationDuration * 1.1 ignoringTouches:YES];
			}
            
		}];
	}/* else {
		[[VLMessageCenter shared] performBlock:^{
			YTImagePickerController *picker = [[[YTImagePickerController alloc] init] autorelease];
			picker.canPickVideo = kYTResourceCanPickVideo;
			[picker showWithSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum
					fromParentView:nil
							  rect:CGRectZero
					   orBarButton:nil
					   resultBlock:^(UIImage *image)
			{
				[self addResourceWithImage:image orVideo:picker.pathToChosenVideo resultBlock:^{
				}];
			}];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
	}*/
}

- (void)addImagesFromAssets:(NSArray *)assets {
    NSLog(@"addImagesFromAssets");
    
    @autoreleasepool {
    
        NSMutableArray *assetsLeft = [NSMutableArray arrayWithArray:assets];
        if([assetsLeft count]) {
            
            NSLog(@"assets count: %lu", (unsigned long)[assetsLeft count]);
            
            _imagesToSaveLeft = (int)assets.count;
            if(!_savingImagesStarted) {
                _savingImagesStarted = YES;
                _imagesToSave = (int)assets.count;
            }
            [self showActivitySaveImages:YES];
            ALAsset *asset = [assetsLeft objectAtIndex:0];
            
            CGImageRef imageCG = [[asset defaultRepresentation] fullResolutionImage];
            
            NSLog(@"image size at full resolution: %dx%d",  (int) CGImageGetWidth(imageCG), (int) CGImageGetHeight(imageCG));
            
            UIImage *image = [UIImage imageWithCGImage:imageCG scale:1.0 orientation: 0];//[[asset valueForProperty:@"ALAssetPropertyOrientation"] intValue]];
            
            NSLog(@"image2 size: %dx%d", (int) image.size.width, (int) image.size.height);
            
            /*NSURL *url = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]];
            NSString *sUrl = [url absoluteString];
            NSString *sType = kYTResourceImageFileExt;
            NSRange range = [sUrl rangeOfString:@"=" options:NSBackwardsSearch];
            if(range.length) {
                NSString *str = [sUrl substringFromIndex:range.location + 1];
                if(str.length <= 4)
                    sType = [str lowercaseString];
            }*/
            
            __weak YTNoteEditView* editView = self;
            
            [self addResourceWithImage:image orVideo:nil resultBlock:^{
                [assetsLeft removeObjectAtIndex:0];
                if([assetsLeft count]) {
                    [editView addImagesFromAssets:assetsLeft];
                } else {
                    
                    NSLog(@"cleaning assets library 2");
                    editView.assetsLibrary = nil;
                    
                    if(_savingImagesStarted) {
                        _imagesToSaveLeft = 0;
                        [self showActivitySaveImages:YES];
                        [[VLMessageCenter shared] performBlock:^{
                            _savingImagesStarted = NO;
                            //[[VLActivityScreen shared] stopActivity];
                            [self showActivitySaveImages:NO];
                        } afterDelay:0.05 ignoringTouches:YES];
                    }
                }
            }];
        }
        else {
            NSLog(@"cleaning assets library");
            self.assetsLibrary = nil;
        }
    }
}

- (void)viewAttachments {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	YTNoteAttachmentsView *view = [[YTNoteAttachmentsView alloc] initWithFrame:CGRectZero];
	view.editMode = YES;
	view.noteEditInfo = self.noteEditInfo;
	[[self parentContentView] pushView:view animated:YES];
	YTAttachment *resourceImage = nil;
	NSMutableArray *resources = [NSMutableArray arrayWithArray: [self.noteEditInfo.note.attachments allObjects]];
	[YTNoteResourcesListView sortResources:resources optionalMainResource:nil];
	for(YTAttachment *info in resources) {
		if([info isImage]/* && !info.isThumbnail*/) {
			resourceImage = info;
			break;
		}
	}
	if(resourceImage)
		[view setCurrentResource:resourceImage];
}

- (void)noteEditItemsView:(YTNoteEditItemsView *)view buttonTapped:(YTNoteEditItemsView_Button *)button withType:(EYTNoteEditButtonType)buttonType {
	YTNoteEditInfo *noteEditInfo = self.noteEditInfo;
	YTNote *note = noteEditInfo.note;
	if(buttonType == EYTNoteEditButtonTypeBook) {
		//[VLCtrlsUtils findAndResignFirstResponder:self];
		YTNotebookSelectView *view = [[YTNotebookSelectView alloc] initWithFrame:CGRectZero];
                
        view.currNotebook = note.notebook;
		view.delegate = self;
		[[self parentContentView] pushView:view animated:YES];
		/*if([[YTNotebooksEnManager shared] getNotebooks].count <= 1 && kYTHideDefaultNotebook) {
			[[VLMessageCenter shared] performBlock:^{
				[view beginSearching];
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
		}*/
	} else if(buttonType == EYTNoteEditButtonTypeLocation) {
		_tryGetCurLocTicket++;
		YTLocation *curLoc = self.noteEditInfo.note.location;
		YTActionSheet *actions = [[YTActionSheet alloc] init];
		NSString *actionUseMyLocation = NSLocalizedString(@"Use My Location", nil);
		NSString *actionSearchMap = NSLocalizedString(@"Search / Map", nil);
		NSString *actionRemoveLocation = NSLocalizedString(@"Remove {Button}", nil);
		[actions addButtonWithTitle:actionUseMyLocation];
		[actions addButtonWithTitle:actionSearchMap];
		if(curLoc) {
			[actions addButtonWithTitle:actionRemoveLocation];
			actions.destructiveButtonIndex = actions.numberOfButtons - 1;
			actions.title = curLoc.name;
		}
		[actions addButtonWithTitle:NSLocalizedString(@"Cancel {Button}", nil)];
		actions.cancelButtonIndex = actions.numberOfButtons - 1;
		[actions showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle)
		{
			if(!btnTitle)
				return;
			if([btnTitle isEqual:actionUseMyLocation]) {
				[self showGettingCurLocationActivity:YES];
				[YTMapSearchView getAddressFromCurrentLocationWithResultBlock:^(YTLocation *resultLocation, NSError *error) {
					[self showGettingCurLocationActivity:NO];
					if(error) {
						VLLogError(error);
						[VLAlertView showWithOkAndTitle:@""
												message:[error localizedDescription]];
						return;
					}
					self.noteEditInfo.note.location = resultLocation;
				}];
			} else if([btnTitle isEqual:actionSearchMap]) {
				YTLocation *objTemp = nil;
				if(self.noteEditInfo.note.location) {
                    //TODO:::see here how location is added to the note
                    NSLog(@"see how location is attached to note");
                    /*
					objTemp = [[[YTLocationInfo alloc] init] autorelease];
					[objTemp assignDataFrom:self.noteEditInfo.locationNew];
					objTemp.locationId = self.noteEditInfo.locationNew.locationId;
                    */
				}
				YTMapSearchView *view = [[YTMapSearchView alloc] initWithFrame:CGRectZero];
				view.delegate = self;
				view.locationInfo = objTemp;
				[[self parentContentView] pushView:view animated:YES];
				if(!objTemp)
					[view startGettingSuggestedLocation];
			} else if([btnTitle isEqual:actionRemoveLocation]) {
				self.noteEditInfo.note.location = nil;
			}
		}];
	} else if(buttonType == EYTNoteEditButtonTypeCamera) {
		int attachmentsCount = 0;
		for(YTAttachment *info in self.noteEditInfo.note.attachments) {
            if([info isImage] || kYTAllowOpenNonImageResources) {
                attachmentsCount++;
            }
		}
		NSString *actionTake = NSLocalizedString(@"Take Photo", nil);
		NSString *actionChoose = NSLocalizedString(@"Choose From Library", nil);
		NSString *actionView = NSLocalizedString(@"View attachments", nil);
		NSString *actionCancel = NSLocalizedString(@"Cancel {Button}", nil);
		YTActionSheet *actionSheet = [[YTActionSheet alloc] init];
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			[actionSheet addButtonWithTitle:actionTake];
		[actionSheet addButtonWithTitle:actionChoose];
		if(attachmentsCount > 0)
			[actionSheet addButtonWithTitle:actionView];
		[actionSheet addButtonWithTitle:actionCancel];
		actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
		[actionSheet showAsyncFromView:nil resultBlock:^(int btnIndex, NSString *btnTitle) {
			if([NSString isEmpty:btnTitle])
				return;
			if([btnTitle isEqual:actionTake]) {
				[self takePhoto];
			} else if([btnTitle isEqual:actionChoose]) {
				[self choosePhoto];
			} else if([btnTitle isEqual:actionView]) {
				[self viewAttachments];
			}
		}];
	} else if(buttonType == EYTNoteEditButtonTypeTag) {
        NSLog(@"tag button tapped");
        
		BOOL wasTagsShown = _tagsShown;
		if(!_tagsShown) {
			[self showTags:YES];
			[[VLMessageCenter shared] performBlock:^{
				if(_tagsShown)
					[_tagsLineView startEditNewTag];
			} afterDelay:wasTagsShown ? 0.1 : kDelayBeginEditTagAfterPull ignoringTouches:YES];
		} else {
			[self showTags:NO];
		}
	} else if(buttonType == EYTNoteEditButtonTypeStarred) {
        //TODO:::favorites/starred
                
        if ([note.isFavorite boolValue]) {
            note.isFavorite = [NSNumber numberWithBool:NO];
        }
        else {
            note.isFavorite = [NSNumber numberWithBool:YES];
        }
        
        [_itemsView enableButtonWithType:EYTNoteEditButtonTypeStarred enable: [note.isFavorite boolValue]];

        //saves the context
        [[DatabaseManager sharedManager] saveContext];
        
	}
}

- (void)onBtnAddTagTapped:(id)sender {
    NSLog(@"onBtnAddTagTapped");
    
	YTSearchTagView *view = [[YTSearchTagView alloc] init];
	view.noteEditInfo = self.noteEditInfo;
	view.delegate = self;
	[[self parentContentView] pushView:view animated:YES];
}

- (void)searchTagView:(YTSearchTagView *)searchTagView finishWithAction:(EYTUserActionType)action {
	[[self parentContentView] popView:searchTagView animated:YES];
	if(action == EYTUserActionTypeDone) {
		NSMutableArray *arrSelTags = [NSMutableArray arrayWithArray:[searchTagView getSelectedTags]];
		[arrSelTags sortUsingComparator:^NSComparisonResult(YTTag *obj1, YTTag *obj2) {
			return [obj1.name compare:obj2.name options:NSCaseInsensitiveSearch];
		}];
		for(YTTag *tag in arrSelTags) {
            [self.noteEditInfo.note addTagsObject: tag];
		}
	}
}

#pragma mark -

- (void)notebookSelectView:(YTNotebookSelectView *)notebookSelectView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDone) {
        
        YTNotebook* notebook = [notebookSelectView getCurrNotebook];
		if(notebook) {
			self.noteEditInfo.note.notebook = notebook;
		}
	}
	[[self parentContentView] popView:notebookSelectView animated:YES];
}

- (void)mapSearchView:(YTMapSearchView *)mapSearchView finishWithAction:(EYTUserActionType)action {
	if(action == EYTUserActionTypeDone) {
		YTLocation *objTemp = mapSearchView.locationInfo;
		if(objTemp != self.noteEditInfo.note.location) {
			self.noteEditInfo.note.location = objTemp;
		} else if(objTemp) {
            //TODO::::add location to note
            //again, i think here we should add location to note
            NSLog(@"Todo::: assign location to note");
			
            //[self.noteEditInfo.locationNew assignDataFrom:objTemp];
			//self.noteEditInfo.noteNew.lastUpdateTS = [VLDate date];
		}
	}
	[[self parentContentView] popView:mapSearchView animated:YES];
}

- (void)addResourceWithImage:(UIImage *)image
					 orVideo:(NSString *)pathToVideo
				 resultBlock:(VLBlockVoid)resultBlock {
	if(!image && [NSString isEmpty:pathToVideo])
		return;
    
//    NSLog(@"addResourceWithImageOrVideo");
    
    
    NSLog(@"input image size: %f %f", image.size.width, image.size.height);
    
	if(image) {
		UIImageOrientation orient = image.imageOrientation;
        if(orient != UIImageOrientationUp || image.size.width > kYTPhotoOriginalMaxSide || image.size.height > kYTPhotoOriginalMaxSide) {
            NSLog(@"will do limit size and rotate");
            image = [image limitSizeAndRotate:kYTPhotoOriginalMaxSide];
        }
	}
	
    NSLog(@"output image size: %f %f", image.size.width, image.size.height);
    
	NSString *fileExt = pathToVideo ? [pathToVideo pathExtension] : nil;
	if([NSString isEmpty:fileExt])
		fileExt = kYTResourceImageFileExt;
	NSString *sPrefix = NSLocalizedString(@"Photo", nil);
	if(![NSString isEmpty:pathToVideo])
		sPrefix = NSLocalizedString(@"Video", nil);

    if(!_activitySaveImages)
        [[VLActivityScreen shared] startActivityWithTitle:NSLocalizedString(@"Saving", nil) yOffset:kActivityYOffset];
    
    //saving attachments
	if(image) {

        //add image attachment
        [[YTAttachmentManager sharedManager] addImageAttachment: image ToNote: self.noteEditInfo.note ResultBlock: ^{
			if(!_activitySaveImages)
				[[VLActivityScreen shared] stopActivity];
            
            NSLog(@"addImage done");
            
			resultBlock();
            
        }];
        
	} else if(![NSString isEmpty:pathToVideo]) {
        
        //add video attachment
        [[YTAttachmentManager sharedManager] addVideoAttachment: pathToVideo ToNote: self.noteEditInfo.note ResultBlock: ^{
			if(!_activitySaveImages)
				[[VLActivityScreen shared] stopActivity];
			resultBlock();
        }];
	} else {
		resultBlock();
	}
    
}



/*
- (NSString *)makeNewFileNameWithPrefix:(NSString *)sPrefix fileExt:(NSString *)fileExt {
	NSDateFormatter *frm = [[[NSDateFormatter alloc] init] autorelease];
	frm.timeZone = [NSTimeZone defaultTimeZone];
	frm.timeStyle = NSDateFormatterMediumStyle;
	frm.dateStyle = NSDateFormatterMediumStyle;
	NSString *fileNameBase = [frm stringFromDate:[NSDate date]];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@" " withString:@"_"];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@"," withString:@"_"];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@"." withString:@"_"];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@";" withString:@"_"];
	fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@":" withString:@" "];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@"," withString:@""];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@"." withString:@""];
	//fileNameBase = [fileNameBase stringByReplacingOccurrencesOfString:@":" withString:@"-"];
	NSMutableArray *entities = [NSMutableArray arrayWithArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:self.noteEditInfo.noteNew.noteGuid].allValues];
	[entities addObjectsFromArray:self.noteEditInfo.resourcesLast];
	[entities addObjectsFromArray:self.noteEditInfo.resourcesNew];
	NSString *fileName;
	for(int i = 0; ; i++) {
		BOOL found = NO;
		if(i == 0)
			fileName = [NSString stringWithFormat:@"%@ %@.%@", sPrefix, fileNameBase, fileExt];
		else
			fileName = [NSString stringWithFormat:@"%@ %@ (%d).%@", sPrefix, fileNameBase, i, fileExt];
		for(YTResourceInfo *obj in entities)
			if([obj.filename compare:fileName options:NSCaseInsensitiveSearch] == 0)
				found = YES;
		if(!found)
			break;
	}
	return fileName;
}
 */

#pragma mark NSLayoutManagerDelegate Delegate

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
	return kYTNoteTitleLineSpacing;
}

#pragma mark -

#pragma mark YTTagsLineViewDelegate Delegate

- (void)tagsLineView:(YTTagsLineView *)view tagRemoved:(YTTag *)tag {
	if([self.noteEditInfo.note.tags count] == 0) {
		[[VLMessageCenter shared] performBlock:^{
			if([self.noteEditInfo.note.tags count] == 0)
				[self showTags:NO];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:NO];
	}
}

#pragma mark -

- (void) removeFromSuperview {
//    NSLog(@"YTNoteEditView::removeFromSuperview");
    
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _tagsLineView = nil;
    _sepTagsBot = nil;
    _tvContent = nil;
    _tvPlaceholder = nil;
    _itemsView = nil;
    _overlayGettingCurLoc = nil;
    _activityGettingCurLoc = nil;
    _activitySaveImages = nil;
    [_timer stop];
    [_timer setObserver:nil selector:nil];
    _timer = nil;
    self.lastText = nil;
    self.lastFirstResponderRef = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardFrameBeginUserInfoKey object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardFrameEndUserInfoKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];
    
	[self showGettingCurLocationActivity:NO];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	if(_activityGettingCurLoc) {
		[_activityGettingCurLoc removeFromSuperview];
	}
	if(_activitySaveImages) {
		[_activitySaveImages removeFromSuperview];
	}
    
    
    [super removeFromSuperview];
}

- (void)dealloc {
    NSLog(@"YTNoteEditView::dealloc");
}

@end
