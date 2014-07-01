
#import <Foundation/Foundation.h>
#import "../Base/Classes.h"
#import "YTNoteResourceRowView.h"

@class YTNoteResourcesListView;


@protocol YTNoteResourcesListViewDelegate <NSObject>
@required
- (void)noteResourcesListView:(YTNoteResourcesListView *)noteResourcesListView rowTapped:(YTNoteResourceRowView *)rowView;

@end


@interface YTNoteResourcesListView : YTBaseView {
@private
	NSObject<YTNoteResourcesListViewDelegate> *__weak _delegate;
	int _maxPhotosToShow;
}

@property (nonatomic, strong) UIView* backViewSep;
@property (nonatomic, strong) NSMutableArray* docsSepars;
@property(nonatomic, weak) NSObject<YTNoteResourcesListViewDelegate> *delegate;
@property(nonatomic, strong) NSMutableArray *resources;
@property(nonatomic, strong) NSMutableArray *rowsViews; // Array of YTNoteResourceRowView
@property(nonatomic, strong) YTAttachment *mainResource;
@property float minHeight;

- (CGSize)sizeThatFits:(CGSize)size;
- (void)onRowTapped:(YTNoteResourceRowView *)rowView;
+ (void)sortResources:(NSMutableArray *)arrYTResourceInfo optionalMainResource:(YTAttachment *)optionalMainResource;
- (BOOL)isAllImagesShown;
- (void)setMaxPhotosToShow:(int)maxPhotosToShow;

@end

