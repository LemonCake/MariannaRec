//
//  RecordingCell.m
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import "RecordingCell.h"
#import "Recording.h"

@interface RecordingCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) Recording *recording;
@end

@implementation RecordingCell

- (void)configureWithRecording:(Recording *)recording {
    self.recording = recording;
    self.titleLabel.text = recording.title;
}

- (IBAction)onEdit:(id)sender {
    if ([self.delegate respondsToSelector:@selector(recordingCell:onEdit:)]) {
        [self.delegate recordingCell:self onEdit:self.recording];
    }
}


@end
