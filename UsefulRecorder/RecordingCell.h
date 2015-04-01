//
//  RecordingCell.h
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordingCellDelegate;

@class Recording;

@interface RecordingCell : UITableViewCell

- (void)configureWithRecording:(Recording *)recording;

@property (nonatomic, assign) id<RecordingCellDelegate> delegate;

@end

@protocol RecordingCellDelegate <NSObject>

@optional
- (void)recordingCell:(RecordingCell *)recordingCell onEdit:(Recording *)recording;

@end
