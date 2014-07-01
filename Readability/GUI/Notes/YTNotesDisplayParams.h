
#import <Foundation/Foundation.h>
#import "../../API/Classes.h"

@interface YTNotesDisplayParams : YTLogicObject {
@private
	YTNotebook *__strong _notebook;
	EYTPriorityType _priorityType;
	NSString *_tagName;
}

@property(nonatomic, strong) YTNotebook* notebook;
@property(nonatomic, assign) EYTPriorityType priorityType;
@property(nonatomic) NSString *tagName;

@end

