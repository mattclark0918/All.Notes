
#import "YTSearchTagView.h"
#import "../Main/Classes.h"
#import "../YTUiMediator.h"

#define kBarBackColor [UIColor colorWithRed:211/255.0 green:215/255.0 blue:218/255.0 alpha:1.0]
#define kTableSeparatorColor [UIColor colorWithWhite:252/255.0 alpha:1.0]

@implementation YTSearchTagView

@synthesize delegate = _delegate;

- (void)initialize {
	[super initialize];
	self.backgroundColor = kYTViewBackColor;
	_searchText = @"";
	_arrSuggestedTagsNames = [[NSMutableArray alloc] init];
	_selectedTagNames = [[NSMutableSet alloc] init];
	
	_navigBar = [[UIView alloc] initWithFrame:CGRectZero];
	_navigBar.backgroundColor = kBarBackColor;
	[self addSubview:_navigBar];
	
	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
	_searchBar.delegate = self;
	_searchBar.placeholder = NSLocalizedString(@"Find a tag {Placeholder}", nil);
	[_searchBar setBackgroundImage:[UIImage imageNamed:@"clear.png"]];
	[self addSubview:_searchBar];
	
	_btnSearchCancel = [UIButton buttonWithType:UIButtonTypeCustom];
	[_btnSearchCancel setTitle:NSLocalizedString(@"Cancel {Button}", nil) forState:UIControlStateNormal];
	[_btnSearchCancel addTarget:self action:@selector(onBtnSearchCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	_btnSearchCancel.alpha = 0.0;
	_btnSearchCancel.hidden = YES;
	[self addSubview:_btnSearchCancel];
	
	_tableView = [[VLKeyboardTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain dataSource:self delegate:self];
	[_tableView setTransparentBackground];
	_tableView.separatorColor = kTableSeparatorColor;
	_tableView.keyboardTableViewDelegate = self;
	[self addSubview:_tableView];
	
	self.customNavBar.titleLabel.text = NSLocalizedString(@"Tags", nil);
	self.customNavBar.btnBack.hidden = NO;
	[self.customNavBar.btnBack addTarget:self action:@selector(onBtnCancelTap:) forControlEvents:UIControlEventTouchUpInside];
	self.customNavBar.btnRight.hidden = NO;
	[self.customNavBar.btnRight setTitle:NSLocalizedString(@"Done {Button}", nil) forState:UIControlStateNormal];
	[self.customNavBar.btnRight addTarget:self action:@selector(onBtnDoneTap:) forControlEvents:UIControlEventTouchUpInside];
	
	UIFont *font = self.customNavBar.titleLabel.font;
	font = [UIFont fontWithName:font.fontName size:font.pointSize - 1];
	self.customNavBar.titleLabel.font = font;
	
	[self updateViewAsync];
}

- (void)onUpdateView {
	[super onUpdateView];
	
    //our current tags
    NSArray* currentTags = [self.noteEditInfo.note.tags allObjects];
    
    //all tags that match our text
    NSArray* tagsMatchSearch = [[YTTagManager sharedManager] findAllTagsStartingWith: _searchText];
    
    //suggested names are all tags matched by tagText minus current tags
    NSMutableArray* suggestedTags = [NSMutableArray arrayWithArray: tagsMatchSearch];
    
    NSLog(@"currentTags count: %d", [currentTags count]);
    NSLog(@"tags match search count: %d", [tagsMatchSearch count]);
    
    //remove tags already existent (so we don't suggest something already exists)
    [suggestedTags removeObjectsInArray: currentTags];
    
    NSMutableArray* suggestedTagsNames = [NSMutableArray arrayWithCapacity: [suggestedTags count]];
    for(YTTag* tag in suggestedTags) {
        [suggestedTagsNames addObject: tag.name];
    }
    
    NSLog(@"suggested tags after removing duplicates: %d", [suggestedTags count]);
    
	[suggestedTagsNames sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
		return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
	}];
    
	if(![_arrSuggestedTagsNames isEqualToArray:suggestedTagsNames]) {
		[_tableView updateRowsWithLastObjects:_arrSuggestedTagsNames
								   newObjects:suggestedTagsNames
								resultObjects:_arrSuggestedTagsNames
									 animated:YES];
		NSMutableSet *setNewTags = [NSMutableSet setWithArray:_arrSuggestedTagsNames];
		for(NSString *tagName in [NSArray arrayWithArray:[_selectedTagNames allObjects]]) {
			if(![setNewTags containsObject:tagName])
				[_selectedTagNames removeObject:tagName];
		}
		for(int i = 0; i < _arrSuggestedTagsNames.count; i++) {
			VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
			if(cell)
				[self updateCell:cell];
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect rcBnds = self.boundsNoBars;
	CGRect rcSearch = rcBnds;
	rcSearch.size.height = [_searchBar sizeThatFits:rcSearch.size].height;
	CGRect rcNavigBar = rcBnds;
	rcNavigBar.size.height = rcSearch.size.height;
	
	float btnOffset = 8;
	CGRect rcBtnSearCanc = rcNavigBar;
	rcBtnSearCanc.size = [_btnSearchCancel sizeThatFits:rcBtnSearCanc.size];
	rcBtnSearCanc.origin.x = CGRectGetMaxX(rcNavigBar) - btnOffset*1.5 - rcBtnSearCanc.size.width;
	rcBtnSearCanc.origin.y = CGRectGetMidY(rcNavigBar) - rcBtnSearCanc.size.height/2;
	
	if(!_btnSearchCancel.hidden && _btnSearchCancel.alpha > 0)
		rcSearch.size.width = rcBtnSearCanc.origin.x - btnOffset - rcSearch.origin.x;
	
	CGRect rcTable = rcBnds;
	rcTable.origin.y = CGRectGetMaxY(rcSearch);
	rcTable.size.height = CGRectGetMaxY(rcBnds) - rcTable.origin.y;
	_searchBar.frame = [UIScreen roundRect:rcSearch];
	_navigBar.frame = [UIScreen roundRect:rcNavigBar];
	_btnSearchCancel.frame = [UIScreen roundRect:rcBtnSearCanc];
	_tableView.frame = [UIScreen roundRect:rcTable];
}

- (void)updateCell:(VLTableViewCell *)cell {
	if(!cell)
		return;
	NSString *tagName = cell.textLabel.text;
	if([_selectedTagNames containsObject:tagName]) {
		if(!cell.accessoryView) {
			cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_check_mark.png"]];
		}
	} else {
		cell.accessoryView = nil;
	}
}

- (UIView *)keyboardTableView:(VLKeyboardTableView *)keyboardTableView getFirstResponder:(id)param; {
	return [VLCtrlsUtils findFirstResponder:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _arrSuggestedTagsNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *reuseId = @"Tag Name Cell";
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView dequeueReusableCellWithIdentifier:reuseId];
	if(!cell) {
		cell = [[VLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
		
		UIView *clearView = [[UIView alloc] initWithFrame:CGRectZero];
		clearView.backgroundColor = [UIColor clearColor];
		cell.backgroundView = clearView;
		cell.backgroundColor = cell.contentView.backgroundColor = [UIColor clearColor];
		cell.layer.borderWidth = cell.contentView.layer.borderWidth = 0;
		cell.layer.shadowColor = cell.contentView.layer.shadowColor = [UIColor clearColor].CGColor;
		
		cell.textLabel.font = [[YTFontsManager shared] fontTableCellLabel];
	}
	NSString *tagName = [_arrSuggestedTagsNames objectAtIndex:indexPath.row];
	cell.textLabel.text = tagName;
	[self updateCell:cell];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
	VLTableViewCell *cell = (VLTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
	NSString *tagName = [_arrSuggestedTagsNames objectAtIndex:indexPath.row];
	if([_selectedTagNames containsObject:tagName]) {
		[_selectedTagNames removeObject:tagName];
	} else {
		[_selectedTagNames addObject:tagName];
	}
	[self updateCell:cell];
}

- (void)setSearchText:(NSString *)searchText {
	if(!searchText)
		searchText = @"";
	if(![_searchText isEqual:searchText]) {
		_searchText = [searchText copy];
		[self updateIsSearching];
		[self updateViewAsync];
	}
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	[self setSearchText:_searchBar.text];
}

- (void)onBtnSearchCancelTap:(id)sender {
	[VLCtrlsUtils findAndResignFirstResponder:self];
	_searchBar.text = @"";
	[self setSearchText:_searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self setSearchText:_searchBar.text];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	_searchBarEditing = YES;
	[self updateIsSearching];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	_searchBarEditing = NO;
	[self updateIsSearching];
}

- (void)setIsSearching:(BOOL)isSearching {
	if(_isSearching != isSearching) {
		if(!isSearching)
			[VLCtrlsUtils findAndResignFirstResponder:self];
		_btnSearchCancel.alpha = _isSearching ? 1 : 0;
		_btnSearchCancel.hidden = NO;
		[UIView animateWithDuration:kDefaultAnimationDuration animations:^{
			_isSearching = isSearching;
			_btnSearchCancel.alpha = _isSearching ? 1 : 0;
			[self layoutSubviews];
		} completion:^(BOOL finished) {
			if(finished) {
				_btnSearchCancel.hidden = !_isSearching;
			}
		}];
		[[YTSlidingContainerView shared] suspendSliding:_isSearching];
	}
}

- (void)updateIsSearching {
	[self setIsSearching:_searchBarEditing || ![NSString isEmpty:_searchText]];
}

- (NSArray *)getSelectedTags {
    return [[YTTagManager sharedManager] getTagsWithNamesInSet: _selectedTagNames];
}

- (void)onBtnCancelTap:(id)sender {
	[self setIsSearching:NO];
	if(_delegate)
		[_delegate searchTagView:self finishWithAction:EYTUserActionTypeCancel];
}

- (void)onBtnDoneTap:(id)sender {
	[self setIsSearching:NO];
	if(_delegate)
		[_delegate searchTagView:self finishWithAction:EYTUserActionTypeDone];
}

- (void)dealloc {
	[self setIsSearching:NO];
}

@end

