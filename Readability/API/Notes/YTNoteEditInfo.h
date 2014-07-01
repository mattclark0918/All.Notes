
#import <Foundation/Foundation.h>
#import "../CoreData/Classes.h"

@interface YTNoteEditInfo : VLLogicObject {
@private
	BOOL _isNewNote;
	YTNote *_note;
}

@property(nonatomic, readonly) BOOL isNewNote;
@property(strong, nonatomic, readonly) YTNote *note;

- (void)initializeWithNoteOriginal:(YTNote *)noteOriginal isNewNote:(BOOL)isNewNote resultBlock:(VLBlockVoid)resultBlock;
- (void)x:(YTNote *)noteOriginal isNewNote:(BOOL)isNewNote resultBlock:(VLBlockVoid)resultBlock;
//- (void)transformToNotNewNote;
- (void)applyChanges;

@end




