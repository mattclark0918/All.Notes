
#import "YTNotesTableView.h"
#import "../Notes/Classes.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"
#import "../../API/Managers/Classes.h"

#define kMinUpdateInterval 1.0
#define kTableHeaderSize 27.0
#define kShowHeaderBottomSeparator NO
#define kCellBorderColor [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1.0]


@implementation YTHomeFeedView_TableHeaderViewBase

@synthesize ivBack = _ivBack;
@synthesize lbTitle = _lbTitle;

- (void)initialize {
	[super initialize];
    
	self.backgroundColor = [UIColor clearColor];
	self.backgroundColor = kYTNoteCellBackColor;
	
	_ivBack = [[UIImageView alloc] initWithFrame:CGRectZero];
	_ivBack.backgroundColor = kYTNoteCellBackColor;//[UIColor clearColor];
	_ivBack.contentMode = UIViewContentModeScaleToFill;
	UIImage *image = [UIImage imageNamed:@"header_reminders_for_today.png"];
	_ivBack.image = image;
	[self addSubview:_ivBack];
	_ivBack.hidden = YES; // Hidden by default
	
	_lbTitle = [[VLLabel alloc] initWithFrame:CGRectZero];
	_lbTitle.backgroundColor = [UIColor clearColor];
	[_lbTitle centerText];
	_lbTitle.textColor = kYTTableHeaderTextColor;
	[self addSubview:_lbTitle];
	
	if(kShowHeaderBottomSeparator) {
		_separator = [[YTNoteTableCellView_Separator alloc] initWithFrame:CGRectZero];
		[self addSubview:_separator];
	}
	
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange addObserver:self selector:@selector(updateViewAsync)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(updateFonts:)];
	[self updateFonts:self];
}

- (void)updateFonts:(id)sender {
	_lbTitle.font = [[YTFontsManager shared] fontWithSize:16 fixed:YES];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
	CGRect rcSep = rcBnds;
	rcSep.size.height = 0;
	if(_separator && !_separator.hidden)
		rcSep.size.height = [_separator optimalHeight];
	rcSep.origin.y = CGRectGetMaxY(rcBnds) - rcSep.size.height;
	if(_separator)
		_separator.frame = rcSep;
	CGRect rcCont = rcBnds;
	rcCont.size.height = rcSep.origin.y - rcBnds.origin.y;
	if(_ivBack)
		_ivBack.frame = rcCont;
	_lbTitle.frame = rcCont;
}

- (CGSize)sizeThatFits:(CGSize)size {
	size.height = kTableHeaderSize;
	if(_separator && !_separator.hidden)
		size.height += [_separator optimalHeight];
	return size;
}

- (void)removeFromSuperview {
    //NSLog(@"YTHomeFeedView_TableHeaderViewBase::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [super removeFromSuperview];
}

- (void)dealloc {
    //NSLog(@"YTHomeFeedView_TableHeaderViewBase::dealloc");
    
	[[VLAppDelegateBase sharedAppDelegateBase].msgrCurrentLocaleDidChange removeObserver:self];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
}

@end


@implementation YTHomeFeedView_RemindersHeaderView

- (void)initialize {
	[super initialize];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	if(rcBnds.size.width < 1 || rcBnds.size.height < 1)
		return;
}

- (void)removeFromSuperview {
    //NSLog(@"YTHomeFeedView_RemindersHeaderView::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [super removeFromSuperview];
}


- (void) dealloc {
    //NSLog(@"YTHomeFeedView_RemindersHeaderView::dealloc");
    
}


@end


@implementation YTHomeFeedView_RecentlyCompletedHeaderView

- (void)initialize {
	[super initialize];
	self.ivBack.image = [UIImage imageNamed:@"cal_recently_completed.png"];
	self.lbTitle.textColor = kYTHeaderButtonTitleColor;
}

- (void)removeFromSuperview {
    //NSLog(@"YTHomeFeedView_RecentlyCompletedHeaderView::removeFromSuperview");
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [super removeFromSuperview];
    
}

- (void) dealloc {
    //NSLog(@"YTHomeFeedView_RecentlyCompletedHeaderView::dealloc");
    
}

@end


@implementation YTHomeFeedView_AllNotesHeaderView

- (void)initialize {
	[super initialize];
	self.lbTitle.text = @"";
	
	_timer = [[VLTimer alloc] init];
	_timer.interval = 10.0; // Update header title (date)
	[_timer setObserver:self selector:@selector(updateViewAsync)];
	[_timer start];
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	NSDateFormatter *frm = [[NSDateFormatter alloc] init];
	frm.timeZone = [NSTimeZone defaultTimeZone];
	frm.timeStyle = NSDateFormatterNoStyle;
	frm.dateFormat = @"MMMM yyyy";
	NSString *sDate = [frm stringFromDate:[NSDate date]];
	self.lbTitle.text = sDate;
}

- (void)layoutSubviews {
	[super layoutSubviews];
}


@end


@implementation YTHomeFeedView_MonthHeaderView

@synthesize dateMonth = _dateMonth;

- (id)init {
	self = [super init];
	if(self) {
		_dateMonth = [NSDate empty];
	}
	return self;
}

- (void)setDateMonth:(NSDate *)dateMonth {
	if(!dateMonth)
		dateMonth = [NSDate empty];
	if(![_dateMonth isEqual:dateMonth]) {
		_dateMonth = dateMonth;
		[self updateViewAsync];
	}
}

- (void)onUpdateView {
	[super onUpdateView];
	NSString *sTitle = @"";
	if(![NSDate isEmpty:_dateMonth]) {
		sTitle = [YTHomeFeedView_MonthSectionInfo stringFromDateMonth:_dateMonth timezone:[NSTimeZone defaultTimeZone]];
	}
	self.lbTitle.text = sTitle;
}


@end


@implementation YTHomeFeedView_MonthSectionInfo

@synthesize dateMonth = _dateMonth;
@synthesize absoluteMonth = _absoluteMonth;
@synthesize notes = _notes;

- (id)init {
	self = [super init];
	if(self) {
		_dateMonth = [NSDate empty];
		_notes = [[NSMutableArray alloc] init];
	}
	return self;
}

+ (NSString *)stringFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone {
	NSDateFormatter *frmMonth = [[NSDateFormatter alloc] init];
	frmMonth.timeZone = timezone;
	frmMonth.dateFormat = @"MMMM yyyy";
	NSString *sMonth = [frmMonth stringFromDate:dateMonth];
	return sMonth;
}

+ (int)absoluteMonthFromDateMonth:(NSDate *)dateMonth timezone:(NSTimeZone *)timezone {
	//return [dateMonth timeIntervalSince1970] / (3600*24*30);
	//int res = [dateMonth diffMonthsFrom:[NSDate dateWithTimeIntervalSinceReferenceDate:0] timezone:timezone];
	int year = [dateMonth gregorianYearWithTimezone:timezone];
	int mon = [dateMonth gregorianMonthWithTimezone:timezone];
	int res = year * 12 + mon;
	return res;
}


@end


@implementation YTNotesTableView

@synthesize hasNotesLoadedOnce = _hasNotesLoadedOnce;

+ (YTNotesTableView *)currentInstance {
    
	NSMutableArray *arrViews = [NSMutableArray arrayWithArray:
								[VLCtrlsUtils getSubViewsOfClass:[YTNotesTableView class] parentView:[UIApplication sharedApplication].keyWindow]];
    
	for(int i = (int) [arrViews count] - 1; i >= 0; i--) {
		YTNotesTableView *view = [arrViews objectAtIndex:i];
		if(view.hidden) {
			[arrViews removeObjectAtIndex:i];
			continue;
		}
	}
    
	return arrViews.count ? [arrViews objectAtIndex:0] : nil;
}

- (id)initWithNotesDisplayParams:(YTNotesDisplayParams *)notesDisplayParams {
	_notesDisplayParams = notesDisplayParams;
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)initialize {
	[super initialize];
	
    //NSLog(@"YTNotesTableView::initialize %@", [NSThread callStackSymbols]);
    
	_arrMonthsSectionsNew = [[NSMutableArray alloc] init];
	_notesSections = [[NSMutableArray alloc] init];
	_notesSectionsNew = [[NSMutableArray alloc] init];
	_dictCellInfoByNoteGuid = [[NSMutableDictionary alloc] init];
	_sectionsHeaders = [[NSMutableArray alloc] init];
	_sectionsHeadersNew = [[NSMutableArray alloc] init];
	_searchText = @"";
	_lastSearchText = @"";
    
    _notesArray = [NSMutableArray arrayWithArray: [[YTNoteManager sharedManager] getNotes]];
	
	_headerToDo = [[YTHomeFeedView_RemindersHeaderView alloc] initWithFrame:CGRectZero];
	_headerToDo.lbTitle.text = NSLocalizedString(@"Reminders for Today", nil);
	_headerToDoDone = [[YTHomeFeedView_RecentlyCompletedHeaderView alloc] initWithFrame:CGRectZero];
	_headerToDoDone.lbTitle.text = NSLocalizedString(@"Recently Completed", nil);
	
	_headerAllNotes = [[YTHomeFeedView_AllNotesHeaderView alloc] initWithFrame:CGRectZero];
	
	_tableView = [[VLKeyboardTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped
												 dataSource:self delegate:self];
    
	[_tableView setTransparentBackground];
	_tableView.separatorColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.delaysContentTouches = NO;
	if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
		[_tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	[self addSubview:_tableView];
	
	float headerHeight = [YTTableSearchBar optimalHeight];
	_tableSearchBar = [[YTTableSearchBar alloc] initWithFrame:CGRectMake(0, -headerHeight, 0, headerHeight)];
	_tableSearchBar.delegate = self;
	if([_tableSearchBar.textField respondsToSelector:@selector(setTintColor:)])
		_tableSearchBar.textField.tintColor = [UIColor colorWithRed:0x5E/255.0 green:0x7D/255.0 blue:0x9A/255.0 alpha:1.0];
	[_tableView addSubview:_tableSearchBar];
	
	_searchOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
	_searchOverlayView.hidden = YES;
	_searchOverlayView.opaque = NO;
	_searchOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
	[self addSubview:_searchOverlayView];
	[_searchOverlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSearchOverlayViewTap:)]];
	
	_timer = [[VLTimer alloc] init];
	[_timer setObserver:self selector:@selector(onTimerEvent:)];
	_timer.interval = kMinUpdateInterval / 4;
	_timer.enabledAlwaysFiring = YES;
	[_timer start];
	[self performSelector:@selector(onTimerEvent:) withObject:nil afterDelay:0.001];
	
    [self startUpdateNotesInBackgroundWithResultBlock:^{
    }];
    
	[[YTUiMediator shared].msgrNoteAddedManually addObserver:self selector:@selector(onNoteAddedManually:args:)];
	
	[[YTFontsManager shared].msgrFontsChanged addObserver:self selector:@selector(onFontsChanged:)];
	[self updateFonts:self];

    
    [self observeContextNotifications];
    
}

//observe for context notifications
- (void) observeContextNotifications {
    
    //TODO:::commented handleDataModelChange for testing purposes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDataModelChange:) name:NSManagedObjectContextObjectsDidChangeNotification object: [DatabaseManager sharedManager].managedObjectContext];
}

//we received an data model change notification
- (void) handleDataModelChange: (NSNotification*) notification {
    NSLog(@"[YTNotesTableView]handleDataModelChange");
    NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
    if ([updatedObjects count] > 0) {
        NSLog(@"has updated objects");
        
        //lets find the note that has been modified
        for(NSManagedObject* obj in updatedObjects) {
            if ([obj isKindOfClass: [YTNote class]]) {
                NSLog(@"[YTNotesTableView] its a notes object");
                
                //now try to find it on our sections
                for(int sectionIndex = 0; sectionIndex < [_notesSections count]; ++sectionIndex) {
                    NSArray* sectionNotes = _notesSections[sectionIndex];
                    
                    BOOL foundNote = NO;
                    
                    for(int noteIndex = 0; noteIndex < [sectionNotes count]; ++noteIndex) {
                        YTNoteTableCellInfo* cellInfo = (YTNoteTableCellInfo*) sectionNotes[noteIndex];
                        
                        YTNote* note = cellInfo.note;
                        
                        if ([obj isEqual: note]) {
                            NSLog(@"[YTNotesTableView] yes, its our note");
                            //NSLog(@"the note has changes? %d", [note hasChanges]);
                            
                            NSArray* indexPaths = @[[NSIndexPath indexPathForRow:noteIndex inSection:sectionIndex]];
                            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                            
//                            [self startUpdateNotesInBackgroundWithResultBlock:^{
//                            }];
                            
                            foundNote = YES;
                            break;
                        }
                    }
                    
                    if (foundNote) {
                        break;
                    }
                }
            }
        }
    }
}


- (void)updateFonts:(id)sender {
	[self setNeedsLayout];
	if(sender != self)
		[_tableView reloadData];
}

- (void)onFontsChanged:(id)sender {
	[self updateFonts:self];
	[_tableView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
	if(_tableSearchBar) {
		float headerHeight = [YTTableSearchBar optimalHeight];
		CGPoint contentOffset = _tableView.contentOffset;
		if(!_searchBarPulled) {
			float pullDY = -contentOffset.y;
			if(pullDY >= headerHeight * 0.67) {
				_searchBarPulled = YES;
				[_tableSearchBar removeFromSuperview];
				contentOffset.y += headerHeight;
				_tableView.tableHeaderView = _tableSearchBar;
				[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
					_tableView.contentOffset = contentOffset;
				}];
			}
		} else {
			float pullDY = contentOffset.y;
			if(pullDY >= headerHeight * 0.5) {
				_searchBarPulled = NO;
				_tableView.tableHeaderView = nil;
				[_tableView addSubview:_tableSearchBar];
				CGRect rcSearch = _tableSearchBar.frame;
				rcSearch.origin.y = -rcSearch.size.height;
				_tableSearchBar.frame = rcSearch;
				CGPoint contentOffsetNew = contentOffset;
				contentOffsetNew.y -= rcSearch.size.height;
				[self layoutSubviews];
				_tableView.contentOffset = contentOffsetNew;
				[_tableSearchBar cancelSearching];
				[self setIsSearching:NO];
				[self setSearchText:@""];
			}
		}
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self beginIsScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if(!decelerate)
		[self endIsScrolling];
	if(_searchBarPulled) {
		float headerHeight = [YTTableSearchBar optimalHeight];
		CGPoint contentOffset = _tableView.contentOffset;
		if(contentOffset.y > 0 && contentOffset.y < headerHeight * 0.5) {
//			[_tableView setContentOffset:CGPointZero animated:YES];
//		return;
            
            //TODO::::1
            
			[_tableView setContentOffset:CGPointMake(0, headerHeight) animated:YES];
			//[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			[[VLMessageCenter shared] performBlock:^{
				_searchBarPulled = NO;
				_tableView.tableHeaderView = nil;
				[_tableView addSubview:_tableSearchBar];
				CGRect rcSearch = _tableSearchBar.frame;
				rcSearch.origin.y = -rcSearch.size.height;
				_tableSearchBar.frame = rcSearch;
				[self layoutSubviews];
				_tableView.contentOffset = CGPointZero;
				[_tableSearchBar cancelSearching];
				[self setIsSearching:NO];
				[self setSearchText:@""];
                self.filteredNotes = nil;
			} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
			//}];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self endIsScrolling];
}

- (void)onSearchOverlayViewTap:(UITapGestureRecognizer *)tap {
	if(tap.state == UIGestureRecognizerStateRecognized) {
		[_tableSearchBar cancelSearching];
		[self setIsSearching:NO];
		[self setSearchText:@""];
        self.filteredNotes = nil;
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.bounds;
	_tableView.frame = rcBnds;
	if(_tableSearchBar) {
		CGRect rcSearch = _tableSearchBar.frame;
		rcSearch.origin.x = _tableView.bounds.origin.x;
		rcSearch.size.width = _tableView.bounds.size.width;
		_tableSearchBar.frame = rcSearch;
	}
	[self updateSearchOverlayViewFrame];
}

/*
- (int64_t)currentManagersVersion {
	int64_t managersVersion = [YTNotesEnManager shared].version
		+ [YTResourcesEnManager shared].version
		+ [YTLocationsEnManager shared].version
		+ [YTNotebooksEnManager shared].version
		+ [YTNoteToResourceEnManager shared].version
		+ [YTNoteToLocationEnManager shared].version;
	return managersVersion;
}
*/
 

- (void)onTimerEvent:(id)sender {
	if([[YTApiMediator shared] isDataInitialized]) {
		if(!_updatingInBackground) {
			if(!_isSearching && ![NSString isEmpty:_lastSearchText]) {
				_lastSearchText = @"";
			}
			//if(_isSearching && ![NSString isEmpty:_searchText]) {
			if(_isSearching) {
				if(![_lastSearchText isEqual:_searchText]) {
					int curSearchingTicket = ++_curSearchingTicket;
					_lastSearchText = [_searchText copy];
					_isSearchingInBackgroundCounter++;
                    
                    //TODO3::: was in background here
                    NSArray* notes = [[YTNoteManager sharedManager] searchNotesWithText:_searchText];
                    
                    _isSearchingInBackgroundCounter--;
                    if(curSearchingTicket != _curSearchingTicket)
                        return;
                    
                    if (![notes isEqualToArray: self.filteredNotes]) {
                        self.filteredNotes = notes;
                        [self startUpdateNotesInBackgroundWithResultBlock:^{
                        }];
                    }
                    
				}
			} else {
                self.filteredNotes = nil;
                /*
				int64_t managersVersion = [self currentManagersVersion];
				if(managersVersion != _lastManagersVersion) {
					NSTimeInterval uptime = [VLTimer systemUptime];
					if(uptime >= _lastUpdateUptime + kMinUpdateInterval) {
						_lastManagersVersion = managersVersion;
                 */
//						[self startUpdateNotesInBackgroundWithResultBlock:^{
//						}];
				//	}
				//}
			}
		}
		if(_isSearching && (_isSearchingInBackgroundCounter > 0 || _updatingInBackground)) {
			if(kYTShowActivityOnBarWhenSearching)
				[_tableSearchBar showActivity:YES];
		} else {
			if(kYTShowActivityOnBarWhenSearching)
				[_tableSearchBar showActivity:NO];
		}
		if(_isSearching && [NSString isEmpty:_tableSearchBar.searchText]) {
			[self updateSearchOverlayViewFrame];
			_searchOverlayView.hidden = NO;
		} else {
			_searchOverlayView.hidden = YES;
		}
	}
}

- (void)updateSearchOverlayViewFrame {
	CGRect rcTable = _tableView.frame;
	CGRect rcBar = [self convertRect:_tableSearchBar.bounds fromView:_tableSearchBar];
	CGRect rcOverlay = rcTable;
	rcOverlay.origin.y = CGRectGetMaxY(rcBar);
	rcOverlay.size.height = CGRectGetMaxY(rcTable) - rcOverlay.origin.y;
	_searchOverlayView.frame = rcOverlay;
}

- (void)startUpdateNotesInBackgroundWithResultBlock:(VLBlockVoid)resultBlock {
    //we're running this on the main thread
    
    NSLog(@"startUpdateNotes %d", [NSThread isMainThread]);
    
	if(_updatingInBackground) {
		int lastUpdatingInBackgroundTicket = _updatingInBackgroundTicket;
		[[VLMessageCenter shared] waitWithCheckBlock:^BOOL{
			return !(_updatingInBackgroundTicket == lastUpdatingInBackgroundTicket);
		} ignoringTouches:NO completeBlock:^{
			resultBlock();
		}];
		return;
	}
	_updatingInBackground = YES;
	_updatingInBackgroundTicket++;
	
    YTNotebook* notebook = _notesDisplayParams.notebook;
    
	EYTPriorityType priorityType = _notesDisplayParams.priorityType;
	NSString *tagName = _notesDisplayParams.tagName;
    
    YTNoteManager* noteMgr = [YTNoteManager sharedManager];
    
	NSMutableArray *arrNotes = nil;
	if(notebook != nil) {
        //notes from a specific notebook
		arrNotes = [NSMutableArray arrayWithArray:[noteMgr getNotesInNotebook: notebook]];
	}
    else if (priorityType > EYTPriorityTypeNone) {
        //favorites
		arrNotes = [NSMutableArray arrayWithArray:[noteMgr getFavoriteNotes]];
    }
    else if (![NSString isEmpty: tagName]) {
        //taggged
        arrNotes = [NSMutableArray arrayWithArray: [noteMgr getNotesWithTagName: tagName]];
    }
    else {
        //all
		arrNotes = [NSMutableArray arrayWithArray:[noteMgr getNotes]];
    }
    
	NSMutableArray *arrCellInfoForModifyVersion = [NSMutableArray array];
	
//	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		
		//NSAutoreleasePool *arpool = [[NSAutoreleasePool alloc] init];
		
		if(_isSearching && self.filteredNotes != nil) {
			for(int i = (int)[arrNotes count] - 1; i >= 0; i--) {
				YTNote *note = [arrNotes objectAtIndex:i];
                if (![self.filteredNotes containsObject: note]) {
                    [arrNotes removeObjectAtIndex: i];
                }
			}
		}
    		      
		[_arrMonthsSectionsNew removeAllObjects];
		[_notesSectionsNew removeAllObjects];
		[_sectionsHeadersNew removeAllObjects];
		
		NSMutableArray *notesSections = [NSMutableArray array];
		NSMutableArray *sectionsHeaders = [NSMutableArray array];
		
		NSMutableArray *notesSectionAll = [NSMutableArray array];
		
		NSMutableDictionary *dictCellInfoByNoteGuid = [[NSMutableDictionary alloc] init];
    
        [notesSectionAll addObjectsFromArray: arrNotes];
    
		[notesSectionAll sortUsingComparator:^NSComparisonResult(YTNote *obj1, YTNote *obj2) {
			int res = [self compareNote:obj1 toNote:obj2];
			return res;
		}];
    
		NSMutableArray *arrMonthsSections = [NSMutableArray array];
		NSMutableDictionary *mapMonthsSections = [NSMutableDictionary dictionary];
		NSTimeZone *tzDef = [NSTimeZone defaultTimeZone];
		for(int i = 0; i < [notesSectionAll count]; i++) {
			YTNote *note = [notesSectionAll objectAtIndex:i];
			VLDate *date =  [[VLDate alloc] initWithNSDate: note.createdDate];
			int nAbsMonth = [YTHomeFeedView_MonthSectionInfo absoluteMonthFromDateMonth:[date toNSDate] timezone:tzDef];
			NSNumber *numAbsMonth = [NSNumber numberWithInt:nAbsMonth];
			YTHomeFeedView_MonthSectionInfo *sectionInfo = [mapMonthsSections objectForKey:numAbsMonth];
			if(!sectionInfo) {
				sectionInfo = [[YTHomeFeedView_MonthSectionInfo alloc] init];
				sectionInfo.dateMonth = [date toNSDate];
				sectionInfo.absoluteMonth = nAbsMonth;
				[mapMonthsSections setObject:sectionInfo forKey:numAbsMonth];
				[arrMonthsSections addObject:sectionInfo];
			}
			[sectionInfo.notes addObject:note];
			[notesSectionAll removeObjectAtIndex:i];
			i--;
		}
    
		for(YTHomeFeedView_MonthSectionInfo *sectionInfo in arrMonthsSections) {
			[sectionInfo.notes sortUsingComparator:^NSComparisonResult(YTNote *obj1, YTNote *obj2) {
				int res = [self compareNote:obj1 toNote:obj2];
				return res;
			}];
		}
        
		[arrMonthsSections sortUsingComparator:^NSComparisonResult(YTHomeFeedView_MonthSectionInfo *obj1, YTHomeFeedView_MonthSectionInfo *obj2) {
			int res = obj1.absoluteMonth - obj2.absoluteMonth;
			return -res;
		}];
		for(YTHomeFeedView_MonthSectionInfo *sectionInfo in arrMonthsSections) {
			[notesSections addObject:sectionInfo.notes];
		}
		NSMutableArray *arrHeaderToDoMonthsAvailable = [NSMutableArray array];
		for(YTHomeFeedView_TableHeaderViewBase *headerBase in _sectionsHeaders) {
			YTHomeFeedView_MonthHeaderView *headerMonth = ObjectCast(headerBase, YTHomeFeedView_MonthHeaderView);
			if(headerMonth)
				[arrHeaderToDoMonthsAvailable addObject:headerMonth];
		}
		for(int i = 0; i < [arrMonthsSections count]; i++) {
			YTHomeFeedView_MonthSectionInfo *sectionInfo = [arrMonthsSections objectAtIndex:i];
			YTHomeFeedView_MonthHeaderView *header = nil;
			if(arrHeaderToDoMonthsAvailable.count) {
				header = [arrHeaderToDoMonthsAvailable objectAtIndex:0];
				[arrHeaderToDoMonthsAvailable removeObjectAtIndex:0];
				header.dateMonth = sectionInfo.dateMonth;
				[sectionsHeaders addObject:header];
			} else {
				[sectionsHeaders addObject:[NSNull null]]; // Create view in the main thread
			}
		}
    
		// Replace notes by cellInfos
		BOOL notesChanged = NO;
		BOOL needChangeAnyCell = NO;
//		int64_t resourcesManagerVersion = manrEnResources.version;
		for(int iSec = 0; iSec < [notesSections count]; iSec++) {
			NSMutableArray *notes = [notesSections objectAtIndex:iSec];
			for(int iNote = 0; iNote < [notes count]; iNote++) {
				YTNote *note = [notes objectAtIndex:iNote];
//				int64_t noteVersion = note.version;
				NSString *noteGuid = note.uniqueIdentifier;
				YTNoteTableCellInfo *cellInfo = nil;
				YTNoteTableCellInfo *existedCellInfo = [_dictCellInfoByNoteGuid objectForKey:noteGuid];
				YTNoteTableCellInfo *existedCellInfoBackup = nil;
				if(existedCellInfo) {
					existedCellInfoBackup = [existedCellInfo copy];
				}
				cellInfo = existedCellInfo;
				if(!cellInfo) {// || cellInfo.lastNoteVersion != noteVersion) {
					cellInfo = [[YTNoteTableCellInfo alloc] init];
					cellInfo.note = note;
                    cellInfo.cachedNumberOfAttachments = (int) [note.attachments count];
				}
                
//                NSLog(@"note content here: %@", note.content);
                
				BOOL noteDataChanged = NO;
				BOOL noteChanged = NO;
				BOOL needChangeCell = NO;
				if(!existedCellInfo)
					noteChanged = YES;
//				else if(noteVersion != existedCellInfo.lastNoteVersion)
//					noteChanged = YES;
				if(noteChanged) {
					noteDataChanged = YES;
					NSString *noteTitle = note.content;
					if([NSString isEmpty:noteTitle])
						noteTitle = [YTNote titlePlaceholder];
					cellInfo.title = noteTitle;
					BOOL showDateLabels = YES;
					if(existedCellInfo && existedCellInfo.showDateLabels != showDateLabels)
						needChangeCell = YES;
					cellInfo.showDateLabels = showDateLabels;
					if(showDateLabels) {
						NSDate *date = note.createdDate;
						NSDateFormatter *frm = [[NSDateFormatter alloc] init];
						frm.timeStyle = NSDateFormatterShortStyle;
						frm.dateStyle = NSDateFormatterNoStyle;
						NSString *sTime = [frm stringFromDate:date];
						cellInfo.strTime = sTime;
						frm = [[NSDateFormatter alloc] init];
						frm.dateFormat = @"dd";
						NSString *sDay = [frm stringFromDate:date];
						if(sDay.length < 2)
							sDay = [NSString stringWithFormat:@"0%@", sDay];
						cellInfo.strDay = sDay;
						frm = [[NSDateFormatter alloc] init];
						frm.dateFormat = @"EEEE";
						NSString *sWeekday = [frm stringFromDate:date];
						cellInfo.strWeekday = [sWeekday uppercaseString];
					} else {
						cellInfo.strTime = nil;
						cellInfo.strDay = nil;
						cellInfo.strWeekday = nil;
					}
				}
                
                if (![note.content isEqualToString: cellInfo.title]) {
                    NSLog(@"changed title");
                    noteDataChanged = YES;
                    cellInfo.title = note.content;
                }
                
				BOOL reassignResource = NO;
                
                if (cellInfo.cachedNumberOfAttachments < [cellInfo.note.attachments count]) {
                    NSLog(@"has new attachments");
                    reassignResource = YES;
                    noteDataChanged = YES;
                }
                
				if(/*resourcesManagerVersion != _lastResourcesManagerVersion ||*/ !existedCellInfo)
					reassignResource = YES;
				if(reassignResource) {
                    
					YTAttachment *resourceImage = nil;
					BOOL hasNonImageResource = NO;
					if([note.attachments count] > 0) {
						for(YTAttachment *res in note.attachments) {
							if([res isImage] && res.preview != nil) {
                                resourceImage = res;
							} else {
								hasNonImageResource = YES;
							}
						}
					}
					BOOL showThumbnail = resourceImage != nil;
					if(cellInfo.showThumbnail != showThumbnail)
						noteDataChanged = YES;
					if(existedCellInfo && existedCellInfo.showThumbnail != showThumbnail)
						needChangeCell = YES;
					cellInfo.showThumbnail = showThumbnail;
					BOOL showAttachmentIcon = hasNonImageResource && !showThumbnail;
					if(cellInfo.showAttachmentIcon != showAttachmentIcon)
						noteDataChanged = YES;
					if(existedCellInfo && existedCellInfo.showAttachmentIcon != showAttachmentIcon)
						needChangeCell = YES;
					cellInfo.showAttachmentIcon = showAttachmentIcon;
					cellInfo.resourceImage = resourceImage;
				}
//				cellInfo.lastNoteVersion = noteVersion;
				if(noteDataChanged)
					notesChanged = YES;
				if(needChangeCell)
					needChangeAnyCell = YES;
				if(existedCellInfo && existedCellInfo == cellInfo && needChangeCell && existedCellInfoBackup) { // Replace with new object, so table cell will be updated
					//cellInfo = [[cellInfo copy] autorelease];
                    
                    NSLog(@"will create new cell info");
                    
					YTNoteTableCellInfo *cellInfoNew = [cellInfo copy];
					[cellInfo assignFrom:existedCellInfoBackup];
					cellInfo = cellInfoNew;
				} else if(cellInfo == existedCellInfo && noteDataChanged) {
					[arrCellInfoForModifyVersion addObject:cellInfo];
                    NSLog(@"WILL ADD FOR MODIFIED");
				}
				[notes replaceObjectAtIndex:iNote withObject:cellInfo];
				[dictCellInfoByNoteGuid setObject:cellInfo forKey:note.uniqueIdentifier];
			}
		}
    
//		_lastResourcesManagerVersion = resourcesManagerVersion;
		
		[_arrMonthsSectionsNew addObjectsFromArray:arrMonthsSections];
		[_notesSectionsNew addObjectsFromArray:notesSections];
		[_sectionsHeadersNew addObjectsFromArray:sectionsHeaders];
		[_dictCellInfoByNoteGuid removeAllObjects];
		[_dictCellInfoByNoteGuid addEntriesFromDictionary:dictCellInfoByNoteGuid];
		
		BOOL headersChanged = ![_sectionsHeaders isEqualToArray:_sectionsHeadersNew];
		BOOL needUpdateTable = notesChanged || headersChanged;
    
        NSLog(@"TABLE VIEW needUpdateTable: %d", needUpdateTable);
    
		if(!needUpdateTable) {
			if([_notesSectionsNew count] != [_notesSections count]) {
				needUpdateTable = YES;
			} else {
				for(int iSec = 0; iSec < [_notesSections count]; iSec++) {
					NSArray *cells = [_notesSections objectAtIndex:iSec];
					NSArray *cellsNew = [_notesSectionsNew objectAtIndex:iSec];
					if([cells count] != [cellsNew count]) {
						needUpdateTable = YES;
						break;
					}
					if([cells isEqualToArray:cellsNew]) {
						needUpdateTable = YES;
						break;
					}
				}
			}
		}
		
		int allNotesVisible = 0;
		for(NSArray *notes in notesSections) {
			allNotesVisible += [notes count];
		}
		
		BOOL needShowEmptyNotesView = NO;
		if(kYTShowEmptyNotesView && allNotesVisible == 0 && !_isSearching && !_notesDisplayParams.priorityType
		   && _notesDisplayParams.notebook == nil && [NSString isEmpty:_notesDisplayParams.tagName])
			needShowEmptyNotesView = YES;
    
//		[arpool drain];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            
			for(int i = 0; i < _arrMonthsSectionsNew.count; i++) {
				YTHomeFeedView_MonthSectionInfo *sectionInfo = [_arrMonthsSectionsNew objectAtIndex:i];
				YTHomeFeedView_MonthHeaderView *header = ObjectCast([_sectionsHeadersNew objectAtIndex:i], YTHomeFeedView_MonthHeaderView);
				if(!header) {
					header = [[YTHomeFeedView_MonthHeaderView alloc] initWithFrame:CGRectZero];
					[_sectionsHeadersNew replaceObjectAtIndex:i withObject:header];
					header.dateMonth = sectionInfo.dateMonth;
				}
			}
			
			if(needUpdateTable) {
                
				if(headersChanged) {
					[_sectionsHeaders removeAllObjects];
					[_sectionsHeaders addObjectsFromArray:_sectionsHeadersNew];
					
					[_notesSections removeAllObjects];
					[_notesSections addObjectsFromArray:_notesSectionsNew];
                    
					[_tableView reloadData];
				} else {
                    
					[_tableView updateRowsWithLastSections:_notesSections
										   newSections:_notesSectionsNew
										resultSections:_notesSections
											  allowMoveRowBetweenSections:YES
												  animated:YES
											  animatedRows:!needChangeAnyCell];
				}
                
			}
			_hasNotesLoadedOnce = YES;
			
//            NSLog(@"_notesSections: %@", _notesSections);
//            NSLog(@"_dictCellInfo: %@", _dictCellInfoByNoteGuid);
            
            
			YTApiMediator *apiMediator = [YTApiMediator shared];
			if([apiMediator isDataInitialized])
				[apiMediator setNotesTableWasLoadadOnce:YES];
			
			if(needShowEmptyNotesView) {
				BOOL wasEmptyNotesView = (_emptyNotesView != nil);
				if(!_emptyNotesView) {
					_emptyNotesView = [[YTEmptyNotesView alloc] initWithFrame:CGRectZero];
				}
				if(_emptyNotesView) {
					float topIndent = 5;//_emptyNotesView.topIndent;
					if(_isSearching)
						topIndent += 32;
					if(_emptyNotesView.topIndent != topIndent) {
						[_emptyNotesView setTopIndent:topIndent animated:wasEmptyNotesView];
					}
				}
				if(_tableView.backgroundView != _emptyNotesView) {
					_lastTableBackView = nil;
					if(_tableView.backgroundView)
						_lastTableBackView = _tableView.backgroundView;
					_tableView.backgroundView = _emptyNotesView;
				}
			} else {
				if(_emptyNotesView && (_tableView.backgroundView == _emptyNotesView)) {
					_tableView.backgroundView = _lastTableBackView;
					_lastTableBackView = nil;
				}
			}
			
			for(YTNoteTableCellInfo *cellInfo in arrCellInfoForModifyVersion) {
                NSLog(@"will modify a cell info");
				[cellInfo modifyVersion];
            }

			_lastUpdateUptime = [VLTimer systemUptime];
			_updatingInBackground = NO;
			_updatingInBackgroundTicket++;
			
			resultBlock();
            
            NSLog(@"end");
            
		});
//	});
}

- (NSComparisonResult)compareNote:(YTNote *)note1 toNote:(YTNote *)note2 {
	int res = -[note1.createdDate compare:note2.createdDate];
	if(res == 0)
		res = [note1.title compare:note2.title options:NSCaseInsensitiveSearch];
	if(res == 0)
		res = [note1.uniqueIdentifier compare:note2.uniqueIdentifier];
	return res;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"numberOfSectionsInTableView: %d", (int) [_notesSections count]);
    
	return [_notesSections count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *cellsInfos = [_notesSections objectAtIndex:section];
//    NSLog(@"number of rows: %d", (int) [cellsInfos count]);
	return [cellsInfos count];
    //return [_notesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"tableView::cellForRow: %ld", (long)indexPath.row);
    static NSString *_reuseIdMapThumbAttachmentIcon = @"_reuseIdMapThumbAttachmentIcon";
    static NSString *_reuseIdMapThumbNoAttachmentIcon = @"_reuseIdMapThumbNoAttachmentIcon";
    static NSString *_reuseIdMapNoThumbAttachmentIcon = @"_reuseIdMapNoThumbAttachmentIcon";
    static NSString *_reuseIdMapNoThumbNoAttachmentIcon = @"_reuseIdMapNoThumbNoAttachmentIcon";
    
    static NSString *_reuseIdNoMapThumbAttachmentIcon = @"_reuseIdNoMapThumbAttachmentIcon";
    static NSString *_reuseIdNoMapThumbNoAttachmentIcon = @"_reuseIdNoMapThumbNoAttachmentIcon";
    static NSString *_reuseIdNoMapNoThumbAttachmentIcon = @"_reuseIdNoMapNoThumbAttachmentIcon";
    static NSString *_reuseIdNoMapNoThumbNoAttachmentIcon = @"_reuseIdNoMapNoThumbNoAttachmentIcon";
    
	NSString *reuseId = _reuseIdNoMapNoThumbNoAttachmentIcon;
    
	NSArray *cellsInfos = [_notesSections objectAtIndex:indexPath.section];
	YTNoteTableCellInfo* cellInfo = [cellsInfos objectAtIndex:indexPath.row];
        
    if (cellInfo.note.location != nil) {
        //we have location
        if(cellInfo.showThumbnail && cellInfo.showAttachmentIcon)
            reuseId = _reuseIdMapThumbAttachmentIcon;
        else if(cellInfo.showThumbnail && !cellInfo.showAttachmentIcon)
            reuseId = _reuseIdMapThumbNoAttachmentIcon;
        else if(!cellInfo.showThumbnail && cellInfo.showAttachmentIcon)
            reuseId = _reuseIdMapNoThumbAttachmentIcon;
        else
            reuseId = _reuseIdMapNoThumbNoAttachmentIcon;
    }
    else {
        //we don't have location
        //without map
        if(cellInfo.showThumbnail && cellInfo.showAttachmentIcon)
            reuseId = _reuseIdNoMapThumbAttachmentIcon;
        else if(cellInfo.showThumbnail && !cellInfo.showAttachmentIcon)
            reuseId = _reuseIdNoMapThumbNoAttachmentIcon;
        else if(!cellInfo.showThumbnail && cellInfo.showAttachmentIcon)
            reuseId = _reuseIdNoMapNoThumbAttachmentIcon;
    }
    
//    reuseId = _reuseIdNoMapNoThumbNoAttachmentIcon;
    
//    NSLog(@"reuseId is %@", reuseId);
    
    /*
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdMapThumbAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdMapThumbNoAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdMapNoThumbAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdMapNoThumbNoAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdNoMapThumbAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdNoMapThumbNoAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdNoMapNoThumbAttachmentIcon];
    [_tableView registerClass: [YTNotesTableViewCell class] forCellReuseIdentifier:_reuseIdNoMapNoThumbNoAttachmentIcon];
    
    //YTNotesTableViewCell *cell = (YTNotesTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:reuseId]
    
	//YTNotesTableViewCell *cell = (YTNotesTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    //TODO:::change to dequeueReusableCellWithIdentifier
    */

    
    YTNotesTableViewCell *cell = (YTNotesTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:reuseId];
    
	if(!cell) {
        
//        NSLog(@"our cell does not exists");
        
		YTNoteTableCellView *view = [[YTNoteTableCellView alloc] initWithFrame:CGRectZero
                                                                      showDate:YES
                                                                 showThumbnail: cellInfo.showThumbnail
                                                            showAttachmentIcon:cellInfo.showAttachmentIcon
                                                                        hasMap: cellInfo.note.location != nil
                                                                          Note:cellInfo.note];

        view.opaque = YES;
    
		cell = [[YTNotesTableViewCell alloc] initWithSubView:view reuseIdentifier:reuseId];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        [cell.layer setBorderWidth:1.0f]; // Aaron Jay - was 0.5f
        [cell.layer setBorderColor:kCellBorderColor.CGColor];
        
        cell.layer.shadowOffset = CGSizeMake(-1, 1);
        cell.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.layer.shadowRadius = 10;
        cell.layer.shadowOpacity = .2;
        cell.opaque = YES;
    
        CGRect shadowFrame = cell.layer.bounds;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        cell.layer.shadowPath = shadowPath;
	}
//    else {
//        NSLog(@"our cell already exists");
//    }
    
    if ([_notesSections count] == 0) {
        return cell;
    }
    
    
    
//    NSLog(@"cell obj is %@", cellInfo);
//    NSLog(@"its note is %@", cellInfo.note);
    
    /*
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdMapThumbAttachmentIcon];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_reuseIdMapThumbAttachmentIcon];
    }
    cell.textLabel.text = [note content];
    return cell;
    */
    
    
//	YTNoteTableCellInfo *cellInfo = ObjectCast(cellObj, YTNoteTableCellInfo);
     
    
	YTNoteTableCellView *view = (YTNoteTableCellView *)cell.subView;
	[view prepareForAddToTable];
	if(view.cellInfo != cellInfo) {
		[view prepareForAddToTable];
		[view applyCellInfo:cellInfo];
	}
    
//    NSLog(@"return cell");
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_notesSections count] == 0) {
        return 44.0;
    }
    
	NSArray *cellsInfos = [_notesSections objectAtIndex:indexPath.section];
	id cellObj = [cellsInfos objectAtIndex:indexPath.row];
    YTNoteTableCellInfo *cellInfo = ObjectCast(cellObj, YTNoteTableCellInfo);
    
	return [YTNoteTableCellView optimalHeight:cellInfo.showThumbnail hasLocation:cellInfo.note.location != nil];
//    return 44.0;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	YTNotesTableViewCell *cell = (YTNotesTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	if(cell) {
		YTNoteTableCellView *view = (YTNoteTableCellView *)cell.subView;
		if(![view canBeSelected])
			return nil;
	}
	return indexPath;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section < _sectionsHeaders.count) {
        YTHomeFeedView_TableHeaderViewBase *header = ObjectCast([_sectionsHeaders objectAtIndex:section], YTHomeFeedView_TableHeaderViewBase);
        if(header) {
            return header;
        }
    }

	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //Calculate the section
    /*
    int sum = 0;
    int nSection = 0;
    for (nSection = 0; nSection < _notesSections.count ; nSection ++) {
        if (section == sum){
            if(nSection < _sectionsHeaders.count) {
                YTHomeFeedView_TableHeaderViewBase *header = ObjectCast([_sectionsHeaders objectAtIndex:nSection], YTHomeFeedView_TableHeaderViewBase);
                if(header) {
                    float height = [header sizeThatFits:self.bounds.size].height;
                    return height;
                }
            }
            
            break;
        }else{
            NSArray *cellsInfos = [_notesSections objectAtIndex:nSection];
            sum += cellsInfos.count;
        }
    }
    */
    
    if(section < _sectionsHeaders.count) {
        YTHomeFeedView_TableHeaderViewBase *header = ObjectCast([_sectionsHeaders objectAtIndex:section], YTHomeFeedView_TableHeaderViewBase);
        if(header) {
            float height = [header sizeThatFits:self.bounds.size].height;
            return height;
        }
    }

	return 0;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	YTNoteTableCellView *cellView = ObjectCast(cell.subView, YTNoteTableCellView);
	if(cellView) {
		[VLCtrlsUtils findAndResignFirstResponder:self];
		YTNote *note = cellView.cellInfo.note;
		YTNoteView *view = (YTNoteView *)[VLCtrlsUtils getSubViewOfClass:[YTNoteView class] parentView:[UIApplication sharedApplication].keyWindow];
		if(view && view.note == note)
			return;
		view = [[YTNoteView alloc] initWithFrame:CGRectZero];
		view.delegate = self;
		view.note = note;
		view.mainResource = cellView.cellInfo.resourceImage;
		[[YTUiMediator shared] showNoteView:view optionalFromCellView:cellView optionalOnThumbsView:nil optionalFromThumbView:nil];
		[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		[_tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
}

- (void)noteView:(YTNoteView *)noteView finishWithAction:(EYTUserActionType)action {
    //NSLog(@"YTNotesTableView::noteView:finishWithAction");
    
	if(action == EYTUserActionTypeDelete) {
		[[YTUiMediator shared] deleteNoteWithNoteView:noteView resultBlock:^(BOOL result) {
			if(result) {
				[[YTSlidingContainerView shared] closeNoteView:noteView toCellView:nil];
			}
		}];
		return;
	}
	[_tableView deselectAllRowsAnimated:YES];
	YTNote *note = noteView.note;
	YTNoteTableCellView *cellView = [self getCellViewByNote:note];
	[[YTSlidingContainerView shared] closeNoteView:noteView toCellView:cellView];
}

- (YTNoteTableCellView *)getCellViewByNote:(YTNote *)note {
	NSArray *visibleCells = [_tableView visibleCells];
	for(UITableViewCell *cell in visibleCells) {
		YTNotesTableViewCell *noteCell = ObjectCast(cell, YTNotesTableViewCell);
		if(noteCell) {
			YTNoteTableCellView *view = ObjectCast(noteCell.subView, YTNoteTableCellView);
			if(view && view.cellInfo && view.cellInfo.note == note)
				return view;
		}
	}
	return nil;
}

- (NSIndexPath *)indexPathForNote:(YTNote *)note {
	for(NSArray *cellsInfos in _notesSections) {
		for(id obj in cellsInfos) {
			YTNoteTableCellInfo *cellInfo = ObjectCast(obj, YTNoteTableCellInfo);
			if(cellInfo && cellInfo.note == note)
				return [NSIndexPath indexPathForRow:[cellsInfos indexOfObject:cellInfo] inSection:[_notesSections indexOfObject:cellsInfos]];
		}
	}
	return nil;
}

- (void)showNote:(YTNote *)note animated:(BOOL)animated {
	[_tableView deselectAllRowsAnimated:YES];
	NSIndexPath *indexPath = [self indexPathForNote:note];
	if(indexPath) {
		/*[_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
		[_tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionNone];
		[[VLMessageCenter shared] performBlock:^{
			[self tableView:_tableView didSelectRowAtIndexPath:indexPath];
		} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];*/
	} else {
		YTNoteView *view = [[YTNoteView alloc] initWithFrame:CGRectZero];
		view.delegate = self;
        //NSLog(@"view.delegate is %@", view.delegate);
		view.note = note;
		[[self parentContentView] pushView:view animated:YES];
	}
}

- (void)onNoteAddedManually:(id)sender args:(YTNote*) note {
    
    //NSLog(@"onNoteAddedManually");
    
    //reload notes
    [self reloadNotes];
    
	[[VLMessageCenter shared] performBlock:^{
		NSIndexPath *indexPath = [self indexPathForNote:note];
		if(indexPath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
                [_tableView flashRow:indexPath];
            });
		}
	} afterDelay:kDefaultAnimationDuration ignoringTouches:YES];
}

#pragma mark - Search

- (void)setIsSearching:(BOOL)isSearching {
	if(_isSearching != isSearching) {
		_isSearching = isSearching;
		[self suspendSliding:_isSearching];
		if(!_isSearching) {
			[self setSearchText:@""];
			_lastManagersVersion = 0;
            
            if (self.filteredNotes != nil) {
                self.filteredNotes = nil;
                [self startUpdateNotesInBackgroundWithResultBlock: ^{}];
            }
            
		}
		YTMainNotesView *parent = (YTMainNotesView *)[VLCtrlsUtils getParentViewOfClass:[YTMainNotesView class] ofView:self];
		[parent setNavigationBarHidden:_isSearching withStatusBarBackColor:_tableSearchBar.backgroundColor animated:YES];
	}
}

- (void)setSearchText:(NSString *)searchText {
    
	if(!searchText)
		searchText = @"";
	if(!_isSearching)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		_searchText = searchText;
		if([NSString isEmpty:_searchText])
			_lastManagersVersion = 0;
	}
        
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchStarted:(id)param {
	[self setIsSearching:YES];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchEnded:(id)param {
    
	[self setIsSearching:NO];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchTextChanged:(NSString *)searchText {
	[self setSearchText:searchText];
}

- (void)tableSearchBar:(YTTableSearchBar *)tableSearchBar searchButtonTapped:(id)param {
	[VLCtrlsUtils findAndResignFirstResponder:self];
}


- (void)removeFromSuperview {
//    NSLog(@"YTNotesTableView::removeFromSuperview %d", [NSThread isMainThread]);

    //manually removing cells: there must be some kind of issue with the memory references
    //because this should be automatic
    for(int i = 0; i < [_notesSections count]; ++i) {
        NSArray* arr = _notesSections[i];
        for(int j = 0; j < [arr count]; ++j) {
            UITableViewCell* cell = [_tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:j inSection:i]];
            if (cell != nil) {
                //NSLog(@"cell at %d, %d: %@", i, j, cell);
                [cell removeFromSuperview];
            }
        }
    }
    
    [_notesSections removeAllObjects];
    [_tableView reloadData];
    
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUiMediator shared].msgrNoteAddedManually removeObserver:self];
	[_tableView resetDataSourceAndDelegate];
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    
    [_notesArray removeAllObjects];
    [_notesSectionsNew removeAllObjects];
    [_dictCellInfoByNoteGuid removeAllObjects];
    
    [[self subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _notesDisplayParams = nil;
    _tableView = nil;
    _tableSearchBar = nil;
    _arrMonthsSectionsNew = nil;
    _notesSections = nil;
    _notesSectionsNew = nil;
    _dictCellInfoByNoteGuid = nil;
    _sectionsHeaders = nil;
    _sectionsHeadersNew = nil;
    _timer = nil;
    _headerToDo = nil;
    _headerToDoDone = nil;
    _headerAllNotes = nil;
    _emptyNotesView = nil;
    _searchText = nil;
    _lastSearchText = nil;
    _searchOverlayView = nil;
    _notesArray = nil;
    
    [super removeFromSuperview];

}

#pragma mark - Memory management

- (void)dealloc {
    //NSLog(@"YTNotesTableView::dealloc");
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];    
    
	[self setIsSearching:NO];
	[[YTFontsManager shared].msgrFontsChanged removeObserver:self];
	[[YTUiMediator shared].msgrNoteAddedManually removeObserver:self];
	[_tableView resetDataSourceAndDelegate];
	_tableSearchBar.delegate = nil;
}

- (void) reloadNotes {
    _notesArray = [NSMutableArray arrayWithArray: [[YTNoteManager sharedManager] getNotes]];
    [self startUpdateNotesInBackgroundWithResultBlock:^{
    }];
}

@end



