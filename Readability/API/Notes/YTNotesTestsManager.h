
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@interface YTNotesTestsManager : YTLogicObject {
@private
}

+ (YTNotesTestsManager *)shared;

- (void)performTest;

@end

