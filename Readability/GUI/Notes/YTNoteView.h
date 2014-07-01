
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteEditView.h"
#import "YTNoteResourcesListView.h"
#import "YTNoteLocationLabelView.h"
#import "YTNoteViewDelegate.h"
#import "YTNoteDateLabelView.h"
#import "YTNoteContentSeparator.h"

@class YTNoteView_SeeMorePhotosView;

@protocol YTNoteView_SeeMorePhotosViewDelegate <NSObject>
@optional
- (void)seeMorePhotosView:(YTNoteView_SeeMorePhotosView *)view tapped:(id)param;
@end

@interface YTNoteView_SeeMorePhotosView_ShadowView : YTBaseView {
@private
}

@end

@interface YTNoteView_SeeMorePhotosView : YTBaseView {
@private
}

@property(nonatomic, weak) NSObject<YTNoteView_SeeMorePhotosViewDelegate> *delegate;
@property(nonatomic, strong) YTNoteView_SeeMorePhotosView_ShadowView *shadowView;
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) VLLabel *lbTitle;


- (void)setTitle:(NSString *)title;

@end


@interface YTNoteView_ContentView : YTBaseView <UIScrollViewDelegate, YTNoteResourcesListViewDelegate,
	YTNoteView_SeeMorePhotosViewDelegate, NSLayoutManagerDelegate> {
@private
    NSString *_lastText;
    BOOL _hasCapitalLine;
    float _heightOfTextView;
    BOOL _contentWasLoaded;
    BOOL _showAllPhotos;
}

@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) YTNoteContentSeparator *sepDateTop;
@property (nonatomic, strong) YTNoteDateLabelView *dateLabelView;
@property (nonatomic, strong) YTNoteContentSeparator *sepDateBot;
@property (nonatomic, strong) YTNoteLocationLabelView *locationLabelView;
@property (nonatomic, strong) YTNoteContentSeparator *sepLocBot;
@property (nonatomic, strong) YTTagsLineView *tagsLineView;
@property (nonatomic, strong) YTNoteResourcesListView *resourcesListViewImages;
@property (nonatomic, strong) YTNoteView_SeeMorePhotosView *seeMorePhotosView;
@property (nonatomic, strong) YTNoteResourcesListView *resourcesListViewDocs;
@property (nonatomic, strong) YTNoteContentSeparator *sepDocsBot;
@property (nonatomic, strong) NSMutableArray *resourcesToShowInList;


- (CGSize)sizeThatFits:(CGSize)size;
- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock;
- (BOOL)isNoteLoaded;
- (BOOL)isAllImagesShown;

@end


@interface YTNoteView : YTBaseView <UIScrollViewDelegate, YTNoteEditViewDelegate> {
@private
    BOOL _wasShown;
    UIStatusBarStyle _statusBarStyleNeededMNV;
    UIStatusBarStyle _lastStatusBarStyleMNV;
    BOOL _toolbarShown;
}

@property(nonatomic, strong) NSObject<YTNoteViewDelegate> *delegate;
@property(nonatomic, strong) YTNoteView_ContentView *contentView;
@property(nonatomic, strong) YTAttachment *mainResource;
@property(nonatomic, strong) UIView *backView;
@property(nonatomic, strong) UIView *toolbar;
@property(nonatomic, strong) UIButton *btnDelete;
@property(nonatomic, strong) UIButton *btnAdd;
@property(nonatomic, strong) UIButton *btnAction;
@property(nonatomic, strong) UIScrollView *contentScrollView;
@property(nonatomic, strong) UIView *statusBarBackViewMNV;

- (void)waitForLoadNoteWithResultBlock:(VLBlockVoid)resultBlock;
- (BOOL)isNoteLoaded;
- (BOOL)isAllImagesShown;
- (UIView *)getContentTextView;
- (void)onShowAnimationBefore;
- (void)onShowAnimationDuring;
- (void)onShowAnimationAfter;
- (void)onCloseAnimationBefore;
- (void)onCloseAnimationDuring;
- (void)onCloseAnimationAfter;
- (void)close;

@end

