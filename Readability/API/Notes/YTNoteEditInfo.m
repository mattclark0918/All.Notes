
#import "YTNoteEditInfo.h"
#import "../Managers/Classes.h"

@implementation YTNoteEditInfo

@synthesize isNewNote = _isNewNote;
@synthesize note = _note;

- (id)init {
	self = [super init];
	if(self) {
		
	}
	return self;
}

- (void)initializeWithNoteOriginal:(YTNote *)noteOriginal isNewNote:(BOOL)isNewNote resultBlock:(VLBlockVoid)resultBlock {
    
	_isNewNote = isNewNote;
    
    _note = noteOriginal;
    
    resultBlock();
    
//	[_noteNew assignDataFrom:_noteLast];
//	_noteNew.modified = NO;
	
//	[_noteLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
//	[_noteNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];

	/* we are doing this on the createNewNoteFrom
	[[YTNotesContentEnManager shared] readNoteContentForNoteWithGuid:_noteLast.noteGuid waitingUntilDone:NO resultBlock:^(YTNoteContentInfo *entity)
	{
		if(entity) {
			_noteContentLast = [entity retain];
		} else {
			_noteContentLast = [[YTNoteContentInfo alloc] init];
			_noteContentLast.noteGuid = _noteLast.noteGuid;
		}
		
		_noteContentNew = [[YTNoteContentInfo alloc] init];
		[_noteContentNew assignDataFrom:_noteContentLast];
		_noteContentNew.modified = NO;
		
		[_noteContentLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		[_noteContentNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		
		_resourcesLast = [[NSMutableArray alloc] initWithArray:[[YTResourcesEnManager shared] getResourcesForNoteWithGuid:_noteContentLast.noteGuid].allValues];
		_tagsLast = [[NSMutableArray alloc] initWithArray:[[YTTagsEnManager shared] getTagsByNoteGuid:_noteLast.noteGuid].allValues];
		_locationLast = [[YTLocationsEnManager shared] getLocationByNoteGuid:_noteLast.noteGuid];
		if(_locationLast) {
			[_locationLast retain];
			[_locationLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		_resourcesNew = [[NSMutableArray alloc] init];
		for(YTResourceInfo *entLast in _resourcesLast) {
			[entLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
			YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
			[entNew assignDataFrom:entLast];
			entNew.modified = NO;
			[_resourcesNew addObject:entNew];
			[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		_tagsNew = [[NSMutableArray alloc] init];
		for(YTTagInfo *entLast in _tagsLast) {
			[entLast.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
			YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
			[entNew assignDataFrom:entLast];
			entNew.modified = NO;
			[_tagsNew addObject:entNew];
			[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		
		if(_locationLast) {
			_locationNew = [[YTLocationInfo alloc] init];
			//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			[_locationNew assignDataFrom:_locationLast];
			_locationNew.modified = NO;
			[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}

		resultBlock();
	}];
    */
}

/*
- (void)transformToNotNewNote {
	if(!_isNewNote)
		return;
	_isNewNote = NO;
	
	if(_noteLast) {
//		[_noteLast.msgrVersionChanged removeObserver:self];
		_noteLast = nil;
	}
	_noteLast = _noteNew;
	_noteNew = nil;

    _noteNew = [[YTNoteManager sharedManager] createNewNoteFrom: _noteLast];
    

//	_noteNew.modified = NO;
//	[_noteNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	if(_noteContentLast) {
		[_noteContentLast.msgrVersionChanged removeObserver:self];
		[_noteContentLast release];
		_noteContentLast = nil;
	}
	_noteContentLast = [_noteContentNew retain];
	[_noteContentNew release];
	_noteContentNew = nil;
	
	_noteContentNew = [[YTNoteContentInfo alloc] init];
	[_noteContentNew assignDataFrom:_noteContentLast];
	_noteContentNew.modified = NO;
	[_noteContentNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	
	if(_locationLast) {
		[_locationLast.msgrVersionChanged removeObserver:self];
		[_locationLast release];
		_locationLast = nil;
	}
	if(_locationNew) {
		_locationLast = [_locationNew retain];
		[_locationNew release];
		_locationNew = nil;
	}
	if(_locationLast) {
		_locationNew = [[YTLocationInfo alloc] init];
		//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
		[_locationNew assignDataFrom:_locationLast];
		_locationNew.modified = NO;
		[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
	
	while(_resourcesLast.count) {
		YTResourceInfo *entity = [_resourcesLast lastObject];
		[entity.msgrVersionChanged removeObserver:self];
		[_resourcesLast removeLastObject];
	}
	[_resourcesLast addObjectsFromArray:_resourcesNew];
	[_resourcesNew removeAllObjects];
	for(YTResourceInfo *entLast in _resourcesLast) {
		YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
		[entNew assignDataFrom:entLast];
		entNew.modified = NO;
		[_resourcesNew addObject:entNew];
		[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
	
	while(_tagsLast.count) {
		YTTagInfo *entity = [_tagsLast lastObject];
		[entity.msgrVersionChanged removeObserver:self];
		[_tagsLast removeLastObject];
	}
	[_tagsLast addObjectsFromArray:_tagsNew];
	[_tagsNew removeAllObjects];
	for(YTTagInfo *entLast in _tagsLast) {
		YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
		[entNew assignDataFrom:entLast];
		entNew.modified = NO;
		[_tagsNew addObject:entNew];
		[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
	}
}
 */

- (void)applyChanges {
    NSLog(@"YTNoteEditInfo::applyChanges");

    //we just save context
    [[DatabaseManager sharedManager] saveContext];
    
    //TODO:::: commented all. Come back later. May change a good amount of the logic.
    //NSLog(@"TODO:::YTNoteEditInfo return back later to this. I commented out everything");
	/*
    
	//if([_noteLast compareDataTo:_noteNew] != 0) {
		////[_noteLast assignDataFrom:_noteNew];
		//VLLoggerWarn(@"%@", @"[_noteLast compareDataTo:_noteNew] != 0. Should have been applied in YTEntitiesManagersLister:applyModifiedNote");
		////[self modifyVersion];
	//}
	
	//if([_noteContentLast compareDataTo:_noteContentNew] != 0) {
		////[_noteContentLast assignDataFrom:_noteContentNew];
		//VLLoggerWarn(@"%@", @"[_noteContentLast compareDataTo:_noteContentNew]. Should have been applied in YTEntitiesManagersLister:applyModifiedNote");
		//[self modifyVersion];
	//}
	
	BOOL locationChanged = NO;
	if(_locationLast != _locationNew)
		locationChanged = YES;
	else if (_locationLast && _locationNew && [_locationLast compareDataTo:_locationNew] != 0)
		locationChanged = YES;
	if(locationChanged) {
		if(_locationLast) {
			[_locationLast.msgrVersionChanged removeObserver:self];
			[_locationLast release];
			_locationLast = nil;
		}
		if(_locationNew) {
			_locationLast = [_locationNew retain];
			[_locationNew release];
			_locationNew = nil;
		}
		if(_locationLast) {
			_locationNew = [[YTLocationInfo alloc] init];
			//_locationNew.locationId = [[YTDatabaseManager shared] makeNewTempId];
			[_locationNew assignDataFrom:_locationLast];
			_locationNew.modified = NO;
			[_locationNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
		}
		_noteNew.hasLocation = (_locationNew != nil);
		[self modifyVersion];
	}
	
	BOOL resourcesChanged = NO;
	if(_resourcesLast.count != _resourcesNew.count)
		resourcesChanged = YES;
	else {
		for(int i = 0; i < _resourcesLast.count; i++) {
			YTResourceInfo *resLast = [_resourcesLast objectAtIndex:i];
			YTResourceInfo *resNew = [_resourcesNew objectAtIndex:i];
			if([resLast compareDataTo:resNew] != 0) {
				resourcesChanged = YES;
				break;
			}
		}
	}
	if(resourcesChanged) {
		for(YTResourceInfo *entity in [NSArray arrayWithArray:_resourcesLast]) {
			if(entity.deleted) {
				[entity.msgrVersionChanged removeObserver:self];
				[_resourcesLast removeObject:entity];
			}
		}
		for(YTResourceInfo *entity in [NSArray arrayWithArray:_resourcesNew]) {
			if([entity isInDb]) {
				[_resourcesLast addObject:entity];
				YTResourceInfo *entNew = [[[YTResourceInfo alloc] init] autorelease];
				[entNew assignDataFrom:entity];
				entNew.modified = NO;
				[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
				[_resourcesNew replaceObjectAtIndex:[_resourcesNew indexOfObject:entity] withObject:entNew];
			}
		}
		[self modifyVersion];
	}
	
	BOOL tagsChanged = NO;
	if(_tagsLast.count != _tagsNew.count)
		tagsChanged = YES;
	else {
		for(int i = 0; i < _tagsLast.count; i++) {
			YTTagInfo *tagLast = [_tagsLast objectAtIndex:i];
			YTTagInfo *tagNew = [_tagsNew objectAtIndex:i];
			if([tagLast compareDataTo:tagNew] != 0) {
				tagsChanged = YES;
				break;
			}
		}
	}
	if(tagsChanged) {
		for(YTTagInfo *entityLast in [NSArray arrayWithArray:_tagsLast]) {
			if(entityLast.deleted) {
				[entityLast.msgrVersionChanged removeObserver:self];
				[_tagsLast removeObject:entityLast];
				continue;
			}
			YTTagInfo *entityNew = nil;
			for(YTTagInfo *entity in _tagsNew) {
				if(entity.tagId == entityLast.tagId) {
					entityNew = entity;
					break;
				}
			}
			if(!entityNew) {
				[entityLast.msgrVersionChanged removeObserver:self];
				[_tagsLast removeObject:entityLast];
				continue;
			}
		}
		for(YTTagInfo *entity in [NSArray arrayWithArray:_tagsNew]) {
			if([entity isInDb]) {
				[_tagsLast addObject:entity];
				YTTagInfo *entNew = [[[YTTagInfo alloc] init] autorelease];
				[entNew assignDataFrom:entity];
				entNew.modified = NO;
				[entNew.msgrVersionChanged addObserver:self selector:@selector(onChildVersionChanged:)];
				[_tagsNew replaceObjectAtIndex:[_tagsNew indexOfObject:entity] withObject:entNew];
			}
		}
		[self modifyVersion];
	}
    */
}

- (void)onChildVersionChanged:(id)sender {
	[self modifyVersion];
}

- (void)onEntityVersionChanged:(id)sender {
	[self modifyVersion];
}

@end







