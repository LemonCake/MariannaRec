//
//  ViewController.m
//  UsefulRecorder
//
//  Created by Joshua Wu on 3/26/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "RecordingsViewController.h"
#import "Recording.h"
#import "DataController.h"
#import "UIAlertView+Blocks.h"
#import "Session.h"
#import "RecordingCell.h"

#import <AVFoundation/AVFoundation.h>

@interface RecordingsViewController () <UITableViewDataSource, UITableViewDelegate, AVAudioRecorderDelegate, RecordingCellDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) Recording *activeTrack;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (weak, nonatomic) IBOutlet UISlider *timeSeeker;
@property (nonatomic, strong) Recording *currentRecording;

@end

@implementation RecordingsViewController

+ (RecordingsViewController *)instantiateWithSession:(Session *)session {
    UIStoryboard *storyboard = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?
                                [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] :
                                [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    RecordingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RecordingsViewController"];
    vc.session = session;
    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - IBAction methods

- (IBAction)onRecordButton:(id)sender {
    static BOOL isRecording = NO;
    isRecording = !isRecording;
    
    if (isRecording) {
        // Start recording track
        [self startNewRecording];
    } else {
        // Stop and save track
        [self stopRecording];
    }
    
    self.recordButton.selected = isRecording;
}

- (IBAction)onSeek:(id)sender {
    self.timeSeeker.value = (int)self.timeSeeker.value;
    self.audioPlayer.currentTime = self.timeSeeker.value;
}

- (IBAction)onSeekValueChange:(id)sender {
    self.timeSeeker.value = (int)self.timeSeeker.value;
    self.timeLabel.text = [self stringFromTimeInterval:self.timeSeeker.value];
}

- (IBAction)onCloseButton:(id)sender {
    [self stopRecording];
    [self stopPlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)startNewRecording {
    [self stopPlayer];
    [self stopRecording];
    
    // Set the audio file
    NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    
    NSArray *pathComponents = @[[[DataController sharedInstance] documentsDirectory],
                                [NSString stringWithFormat:@"recording_%lu.aac", (unsigned long) dateString.hash]];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    if([[AVAudioSession sharedInstance] isInputGainSettable]) {
        NSError* err = nil;
        [[AVAudioSession sharedInstance] setInputGain:1.2f error:&err];
    }
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    [recordSetting setValue:@44100.0F forKey:AVSampleRateKey];
    [recordSetting setValue:@1 forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    [self.audioRecorder record];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.timeSeeker.alpha = 0.0f;
        self.recordButton.alpha = 1.0f;
    }];
    
    [self startTimer];
}

- (void)stopRecording {
    [self.audioRecorder stop];
    self.audioRecorder = nil;
    [self.updateTimer invalidate];
}

- (void)stopPlayer {
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    self.activeTrack = nil;
    [self.updateTimer invalidate];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.timeSeeker.alpha = 0.0f;
    }];
}

- (void)playRecording:(Recording *)recording {
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [self stopPlayer];
    [self stopRecording];
    
    NSError *err = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[DataController sharedInstance] urlForRecording:recording] error:&err];
    
    if (err) {
        [UIAlertView showWithTitle:@"Oops" message:err.description cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:nil];
        return;
    }
    
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
    
    self.timeSeeker.maximumValue = (int)self.audioPlayer.duration;
    self.timeSeeker.value = 0;
    
    [self startTimer];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.timeSeeker.alpha = 1.0f;
    }];
    
    self.currentRecording = recording;
    [self.tableView reloadData];
}

- (void)startTimer {
    [self.updateTimer invalidate];
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [self.updateTimer fire];
}

- (void)updateTimer:(NSTimer *)timer {
    if (self.audioPlayer.isPlaying) {
        self.timeSeeker.value = self.audioPlayer.currentTime;
        self.timeLabel.text = [self stringFromTimeInterval:self.audioPlayer.currentTime];
    } else if (self.audioRecorder.isRecording) {
        self.timeLabel.text = [self stringFromTimeInterval:self.audioRecorder.currentTime];
    }
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    return [NSString stringWithFormat:@"%li:%02li", (long)minutes, (long)seconds];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSUInteger nextIndex = [self.session.recordings indexOfObject:self.currentRecording] + 1;
    
    if (nextIndex < self.session.recordings.count) {
        Recording *next = self.session.recordings[nextIndex];
        [self playRecording:next];
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    Recording *thisTrack = [[Recording alloc] init];
    thisTrack.filePath = recorder.url.pathComponents.lastObject;
    thisTrack.title = [NSString stringWithFormat:@"Track %lu", (unsigned long)self.session.recordings.count];
    [[DataController sharedInstance] createRecording:thisTrack session:self.session];
    
    [self.tableView reloadData];
    
    NSLog(@"Done Recording: %@", recorder.url);
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *RECORDING_CELL = @"RECORDING_CELL";
    
    Recording *thisTrack = (self.session.recordings)[(NSUInteger) indexPath.row];
    
    RecordingCell *cell = [tableView dequeueReusableCellWithIdentifier:RECORDING_CELL forIndexPath:indexPath];
    [cell configureWithRecording:thisTrack];
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.session.recordings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    RecordingCell *rCell = (RecordingCell *)cell;
    if (rCell.recording == self.currentRecording) {
        [rCell setHighlighted:YES];
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Recording *thisTrack = self.session.recordings[(NSUInteger) indexPath.row];
    if (self.activeTrack == thisTrack) {
        [self stopPlayer];
    } else {
        [self playRecording:thisTrack];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[DataController sharedInstance] deleteRecording:self.session.recordings[(NSUInteger) indexPath.row] session:self.session];
        [self.tableView reloadData];
    }
}

#pragma mark - RecordingCellDelegate methods

- (void)recordingCell:(RecordingCell *)recordingCell onEdit:(Recording *)track {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Rename recording"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Rename", nil];
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [av textFieldAtIndex:0].text = recordingCell.recording.title;

    MagicBlockWeakSelf weakSelf = self;
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex && [av textFieldAtIndex:0].text.length > 0) {
            [[DataController sharedInstance] renameTrack:track title:[alertView textFieldAtIndex:0].text];
            [weakSelf.tableView reloadData];
        }
    };
    
    [av show];
}

@end
