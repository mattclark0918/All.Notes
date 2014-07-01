
#import "YTNotesDisplayParams.h"

@implementation YTNotesDisplayParams

@synthesize notebook = _notebook;
@synthesize priorityType = _priorityType;
@synthesize tagName = _tagName;

- (id)init {
	self = [super init];
	if(self) {
		_tagName = @"";
	}
	return self;
}

- (void)setPriorityType:(EYTPriorityType)priorityType {
	if(_priorityType != priorityType) {
		_priorityType = priorityType;
		[self modifyVersion];
	}
}

- (void)setTagName:(NSString *)tagName {
	if(!tagName)
		tagName = @"";
	if(![_tagName isEqual:tagName]) {
		_tagName = [tagName copy];
		[self modifyVersion];
	}
}


@end

