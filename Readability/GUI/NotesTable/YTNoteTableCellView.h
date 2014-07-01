
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteTableCellInfo.h"
#import "../Resources/Classes.h"
#import "YTNoteCellTextView.h"
#import "YTNoteView.h"
#import "AsyncImageView.h"
#import "YTPhotosMosaicView.h"

@class YTNoteTableCellView_ThumbFrame;
@class YTNoteTableCellView_Separator;


@interface YTNoteTableCellViewManager : YTLogicObject {
@private
}

+ (YTNoteTableCellViewManager *)shared;
- (void)initialize;

@end



@interface YTNoteTableCellView : YTBaseView <YTNoteResourcesListViewDelegate> {
@private
	YTNoteCellTextView *_textView;
	BOOL _showThumbnail;
	BOOL _showAttachmentIcon;
    BOOL _hasMap;
	YTAttachment *_resourceImage;
	BOOL _showDate;
	VLLabel *_lbDateDay;
	VLLabel *_lbDateWeekday;
    YTNoteLocationLabelView *_locationLabelView;
	UIImageView *_iconAttachment;
	YTNoteTableCellView_Separator *_separator;
	YTNoteTableCellInfo __weak *_cellInfo;
    
    //Mosaic Image View
    YTPhotosMosaicView *_photoThumbsView;
    
    //Map View
    AsyncImageView *_mapView;
}

@property(nonatomic, weak, readonly) YTNoteTableCellInfo *cellInfo;
@property(nonatomic, readonly) YTNoteCellTextView *textView;
@property(weak, nonatomic, readonly) YTResourceImageView *thumbnailView;
@property(nonatomic, readonly) YTAttachment *resourceImage;
@property(nonatomic,  readonly) AsyncImageView *mapView;
@property(nonatomic, readonly) YTPhotosMosaicView *photoThumbsView;

+ (float)contentHeight:(BOOL)showThumb hasLocation:(BOOL)hasLocation;
+ (float)optimalHeight:(BOOL)showThumb hasLocation:(BOOL)hasLocation;

- (id)initWithFrame:(CGRect)frame
           showDate:(BOOL)showDate
      showThumbnail:(BOOL)showThumbnail
 showAttachmentIcon:(BOOL)showAttachmentIcon
             hasMap:(BOOL)hasMap
               Note:(YTNote*) note;

- (void)prepareForAddToTable;
- (void)applyCellInfo:(YTNoteTableCellInfo *)cellInfo;
- (void)onSelectedChanged:(BOOL)selected;
- (BOOL)canBeSelected;
- (void)showThumbnailFrame:(BOOL)show animated:(BOOL)animated;



@end


@interface YTNotesTableViewCell : VLTableViewCell {
@private
	BOOL _lastSelected;
}

@end


@interface YTNoteTableCellView_Separator : YTBaseView {
@private
}

- (float)optimalHeight;

@end





