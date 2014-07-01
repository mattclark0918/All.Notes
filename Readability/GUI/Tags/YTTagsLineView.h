
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "../Ctrls/Classes.h"

@class YTTagsLineView;

@interface YTTagsLineView_TagView : YTBaseView {
@private
	VLLabel *_labelTitle;
	BOOL _isBlank;
	BOOL _isEditing;
	UITextField *_textField;
}

@property(nonatomic, assign) BOOL isEditing;
@property(nonatomic, readonly) UITextField *textField;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *editedTitle;

- (id)initWithFrame:(CGRect)frame isBlank:(BOOL)isBlank;

@end


@interface YTTagsLineView_ContentView : YTBaseView {
@private
}

@end


@protocol YTTagsLineViewDelegate <NSObject>
@optional
- (void)tagsLineView:(YTTagsLineView *)view tagRemoved:(YTTag *)tag;
@end


@interface YTTagsLineView : YTBaseView <UIScrollViewDelegate, UITextFieldDelegate, VLPopupBubbleMenuViewDelegate> {
@private
	BOOL _allowEditing;
	UIButton *_buttonAdd;
	NSMutableArray *_tagsViews;
	BOOL _tagsListBuilt;
	VLTimer *_timer;
	NSObject<YTTagsLineViewDelegate> *__weak _delegate;
}

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) YTTagsLineView_ContentView* contentView;
@property (nonatomic, strong) YTTagsLineView_TagView* blankTagView;
@property (nonatomic, strong) VLPopupBubbleMenuView* popupBubbleMenuView;
@property (nonatomic, strong) YTTagsLineView_TagView *editedTagView;
@property (nonatomic, strong) YTTagsLineView_TagView *popupTargetTagView;
@property (nonatomic, strong) VLTimer *timer;




@property(nonatomic, assign) BOOL allowEditing;
@property(nonatomic, readonly) UIButton *buttonAdd;
@property(nonatomic, readonly) BOOL popupMenuShown;
@property(nonatomic, weak) NSObject<YTTagsLineViewDelegate> *delegate;

//the number of tags we're currently displaying
@property (nonatomic) NSInteger numberOfTags;

- (void)startEditNewTag;
- (void)stopEditingTag;

@end

