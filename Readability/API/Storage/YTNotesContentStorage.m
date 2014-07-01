
#import "YTNotesContentStorage.h"
#import "../Notes/Classes.h"

static YTNotesContentStorage *_shared;

@implementation YTNotesContentStorage
+ (YTNotesContentStorage *)shared {
	if(!_shared)
		_shared = [[YTNotesContentStorage alloc] init];
	return _shared;
}

- (id)init {
	self = [super init];
	if(self) {
		_shared = self;
		
		_dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_dirPath = [_dirPath stringByAppendingPathComponent:@"YTNotesContentStorage"];
	}
	return self;
}


@end

