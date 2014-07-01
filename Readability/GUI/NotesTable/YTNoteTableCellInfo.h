
#import <Foundation/Foundation.h>
#import "../../API/Classes.h"

@interface YTNoteTableCellInfo : VLLogicObject <NSCopying> {
@private
	YTNote *_note;
	int64_t _lastNoteVersion;
	BOOL _showThumbnail;
	BOOL _showAttachmentIcon;
	YTAttachment *_resourceImage;
	NSString *_title;
	BOOL _showDateLabels;
	NSString *_strTime;
	NSString *_strDay;
	NSString *_strWeekday;
}

@property(nonatomic, strong) YTNote *note;
@property(nonatomic, assign) int64_t lastNoteVersion;
@property(nonatomic, assign) BOOL showThumbnail;
@property(nonatomic, assign) BOOL showAttachmentIcon;
@property(nonatomic, strong) YTAttachment *resourceImage;
@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) BOOL showDateLabels;
@property(nonatomic, strong) NSString *strTime;
@property(nonatomic, strong) NSString *strDay;
@property(nonatomic, strong) NSString *strWeekday;

@property (nonatomic) int cachedNumberOfAttachments;

- (BOOL)isEqual:(id)object;
- (void)assignFrom:(YTNoteTableCellInfo *)other;
- (id)copyWithZone:(NSZone *)zone;

@end

