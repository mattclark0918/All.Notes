
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"
#import "YTNoteEditItemsView.h"
#import "../Notebook/Classes.h"
#import "YTMapSearchView.h"
#import "../ELCImagePicker/Classes.h"
#import "../Tags/Classes.h"
#import "YTSearchTagView.h"

@class YTNoteEditView;
@class YTNoteContentSeparator;

@protocol YTNoteEditViewDelegate <NSObject>
@required
- (void)noteEditView:(YTNoteEditView *)noteEditView finishWithAction:(EYTUserActionType)action;

@end

@interface YTNoteEditView_PlaceholderView : VLLabel {
@private
}

@end


@interface YTNoteEditView : YTBaseView <UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate,
	YTNoteEditItemsViewDelegate, YTNotebookSelectViewDelegate, YTMapSearchViewDelegate,
	YTSearchTagViewDelegate, NSLayoutManagerDelegate, YTTagsLineViewDelegate> {
@private
	BOOL _isNoteContentHtml;
	BOOL _startEditTitleAfterOpen;
	BOOL _keyboardShown;
	CGRect _frameOfKeyboard;
	BOOL _triedGetCurLocation;
	int _tryGetCurLocTicket;
	BOOL _wasFirstResponder;
	BOOL _isNewNote;
	int _gettingCurrentLocationCounter;
	BOOL _showingGettingCurLocActivity;
	BOOL _tagsShown;
	BOOL _animatingShowingTags;
	BOOL _isScrollingNEV;
	BOOL _savingImagesStarted;
	int64_t _lastAutoSavedDataVersion;
	BOOL _isAutoSaving;
	NSTimeInterval _lastAutosavedUptime;
	BOOL _newNoteNeedsAutosave;
	int _imagesToSave;
	int _imagesToSaveLeft;
	int _pickerShownCounter;
}

@property (nonatomic, strong) VLTimer *timer;
@property (nonatomic, strong) YTNoteContentSeparator *sepTagsBot;
@property (nonatomic, strong) UITextView *tvContent;
@property (nonatomic, strong) YTNoteEditView_PlaceholderView *tvPlaceholder;
@property (nonatomic, strong) NSString *lastText;
@property (nonatomic, strong) YTNoteEditItemsView *itemsView;
@property (nonatomic, strong) UIView *lastFirstResponderRef;
@property (nonatomic, strong) UIView *overlayGettingCurLoc;
@property (nonatomic, strong) YTActivityView *activityGettingCurLoc;
@property (nonatomic, strong) YTActivityView *activitySaveImages;

@property (nonatomic, strong) YTTagsLineView* tagsLineView;

@property(nonatomic, weak) NSObject<YTNoteEditViewDelegate> *delegate;
@property(nonatomic, assign) BOOL startEditTitleAfterOpen;
@property(nonatomic, assign) BOOL isNewNote;

//our assets library
@property (nonatomic, strong) ALAssetsLibrary* assetsLibrary;

- (void)initializeWithNoteEditInfo:(YTNoteEditInfo *)noteEditInfo previousScreenTitle:(NSString *)previousScreenTitle;
- (void)initializeWithNote:(YTNote *)note;
- (void)addImagesFromAssets:(NSArray *)assets;
- (void)addResourceWithImage:(UIImage *)image
					 orVideo:(NSString *)pathToVideo
				 resultBlock:(VLBlockVoid)resultBlock;

@end
