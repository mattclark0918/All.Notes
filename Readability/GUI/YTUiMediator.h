
#import <Foundation/Foundation.h>
#import "Base/Classes.h"
#import "NoteEdit/Classes.h"
#import "Resources/Classes.h"

@class YTNoteView;
@class YTNoteTableCellView;

@interface YTUiMediator : YTLogicObject <YTNoteEditViewDelegate> {
@private
	int64_t _savedDataVersion;
	VLMessenger *_msgrNoteAddedManually;
	VLMessenger *_msgrFileCantBeViewedAlerted;
	int _isScrollingCounter;
	VLMessenger *_msgrScrollingEnded;
}

@property(nonatomic, readonly) VLMessenger *msgrNoteAddedManually;
@property(nonatomic, readonly) VLMessenger *msgrFileCantBeViewedAlerted;
@property(nonatomic, readonly) VLMessenger *msgrScrollingEnded;

@property (nonatomic, strong) YTImagePickerController* picker;

+ (YTUiMediator *)shared;

- (YTNotebook *)notebookForNewNotes;
//- (YTStackInfo *)mainStack;
- (void)deleteNoteWithNoteView:(YTNoteView *)noteView resultBlock:(VLBlockBool)resultBlock;

- (void)startAddNewNoteAsPhoto:(BOOL)asPhoto
                      Notebook:(YTNotebook *)notebook
                     isStarred:(BOOL)isStarred
           previousScreenTitle:(NSString *)previousScreenTitle;

- (void)startAddNewNote:(YTNote *)note;

- (void)startEditNote:(YTNote *)note
  previousScreenTitle:(NSString *)previousScreenTitle;

- (void)showNoteView:(YTNoteView *)noteView
		optionalFromCellView:(YTNoteTableCellView *)noteCellView
	optionalOnThumbsView:(YTPhotosThumbsView *)thumbsView
	optionalFromThumbView:(YTPhotosThumbsView_ThumbView *)thumbView;
- (void)saveTakenPhotoToCameraRoll:(UIImage *)image;

- (void)beginIsScrolling;
- (void)endIsScrolling;
- (BOOL)isScrolling;

@end

