//
//  DataController.h
//  UsefulRecorder
//
//  Created by Joshua Wu on 4/2/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataControllerCompletionBlock)(void);

@class Recording;
@class Session;
@interface DataController : NSObject

+ (DataController *)sharedInstance;
- (NSArray *)allSessions;
- (void)createNewSession:(NSString *)session completion:(DataControllerCompletionBlock)completion;
- (void)deleteSession:(Session *)session;
- (void)createRecording:(Recording *)recording session:(Session *)session;
- (void)deleteRecording:(Recording *)recording session:(Session *)session;
- (void)renameSession:(Session *)session title:(NSString *)title;
- (void)renameTrack:(Recording *)recording title:(NSString *)title;
- (NSString *)documentsDirectory;
- (NSURL *)urlForRecording:(Recording *)recording;

@end
