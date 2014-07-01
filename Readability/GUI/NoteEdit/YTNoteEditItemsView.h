
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"

@class YTNoteEditItemsView;
@class YTNoteEditItemsView_Button;


typedef enum
{
	EYTNoteEditButtonTypeNone = 0,
	EYTNoteEditButtonTypeBook,
	EYTNoteEditButtonTypeLocation,
	EYTNoteEditButtonTypeCamera,
	EYTNoteEditButtonTypeMic,
	EYTNoteEditButtonTypeAttachment,
	EYTNoteEditButtonTypeCalendar,
	EYTNoteEditButtonTypeReminder,
	EYTNoteEditButtonTypeTag,
	EYTNoteEditButtonTypeStarred
}
EYTNoteEditButtonType;


@protocol YTNoteEditItemsViewDelegate <NSObject>
@optional
- (void)noteEditItemsView:(YTNoteEditItemsView *)view buttonTapped:(YTNoteEditItemsView_Button *)button withType:(EYTNoteEditButtonType)buttonType;
@end


@protocol YTNoteEditItemsView_ButtonDelegate <NSObject>
@optional
- (void)noteEditItemsView_Button:(YTNoteEditItemsView_Button *)button tappedWithType:(EYTNoteEditButtonType)buttonType;
@end


@interface YTNoteEditItemsView_Button : YTBaseView {
@private
	EYTNoteEditButtonType _type;
	UIImage *_icon;
	UIImage *_iconGrayed;
	NSObject<YTNoteEditItemsView_ButtonDelegate> *__weak _delegate;
	BOOL _touched;
	BOOL _grayed;
}

@property(nonatomic, assign) EYTNoteEditButtonType type;
@property(nonatomic, strong) UIImage *icon;
@property(nonatomic, strong) UIImage *iconGrayed;
@property(nonatomic, weak) NSObject<YTNoteEditItemsView_ButtonDelegate> *delegate;
@property(nonatomic, assign) BOOL grayed;
@property(nonatomic, strong) NSString *badgeText;
@property(nonatomic, strong) UIButton *buttonIcon;
@property(nonatomic, strong) VLLabel *labelBadge;


- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable;

@end





@interface YTNoteEditItemsView : YTBaseView <YTNoteEditItemsView_ButtonDelegate> {
@private
	YTNoteEditItemsView_Button *_buttonTag;
	YTNoteEditItemsView_Button *_buttonLocation;
	YTNoteEditItemsView_Button *_buttonCamera;
	YTNoteEditItemsView_Button *_buttonStar;
	YTNoteEditItemsView_Button *_buttonBook;
	NSObject<YTNoteEditItemsViewDelegate> *__weak _delegate;
}

@property(nonatomic, strong) NSMutableArray *allButtons;
@property(nonatomic, strong) NSMutableArray *visibleButtons;
@property(nonatomic, weak) NSObject<YTNoteEditItemsViewDelegate> *delegate;
@property(nonatomic, strong) YTNoteEditItemsView_Button *buttonTag;
@property(nonatomic, strong) YTNoteEditItemsView_Button *buttonLocation;
@property(nonatomic, strong) YTNoteEditItemsView_Button *buttonCamera;
@property(nonatomic, strong) YTNoteEditItemsView_Button *buttonStar;
@property(nonatomic, strong) YTNoteEditItemsView_Button *buttonBook;

- (void)showButtonWithType:(EYTNoteEditButtonType)type show:(BOOL)show;
- (void)enableButtonWithType:(EYTNoteEditButtonType)type enable:(BOOL)enable;

@end

