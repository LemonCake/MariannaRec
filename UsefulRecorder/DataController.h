//
//  DataController.h
//  UsefulRecorder
//
//  Created by Joshua Wu on 4/2/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataControllerCompletionBlock)(BOOL success);

@class Recording;
@interface DataController : NSObject

+ (DataController *)sharedInstance;
- (NSArray *)allSessions;
- (NSMutableArray *)getRecordingsForSession:(NSString *)session;
- (void)createNewSession:(NSString *)session completion:(DataControllerCompletionBlock)completion;
- (void)deleteSession:(NSString *)session;
- (void)createRecording:(Recording *)recording session:(NSString *)session;
- (void)deleteRecording:(Recording *)recording session:(NSString *)session;

- (NSString *)documentsDirectory;
- (NSURL *)urlForRecording:(Recording *)recording;
@end
