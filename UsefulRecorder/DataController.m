//
//  DataController.m
//  UsefulRecorder
//
//  Created by Joshua Wu on 4/2/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "DataController.h"
#import "Recording.h"

static NSString *kSessionsKey = @"sessions_and_recordings";

@interface DataController()

@property (nonatomic, strong) NSMutableDictionary *data;

@end

@implementation DataController

+ (DataController *)sharedInstance {
    static dispatch_once_t onceToken;
    static DataController *dataController = nil;
    
    dispatch_once(&onceToken, ^{
        dataController = [[DataController alloc] init];
    });
    
    return dataController;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self loadData];
    }
    
    return self;
}

- (void)loadData {
    self.data = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kSessionsKey]];
    
    if (!self.data) {
        self.data = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:self.data forKey:kSessionsKey];
        [self save];
    }
}

- (void)createNewSession:(NSString *)session completion:(DataControllerCompletionBlock)completion {
    if ((self.data)[session]) {
        if (completion) {
            completion(NO);
        }
    } else {
        (self.data)[session] = [NSMutableArray array];
        [self save];
        
        if (completion) {
            completion(YES);
        }
    }
}

- (void)deleteSession:(NSString *)session {
    for (Recording *recording in (self.data)[session]) {
        [self deleteFileAtPath:[self urlForRecording:recording]];
    }
    
    [self.data removeObjectForKey:session];
    [self save];
}

- (void)deleteFileAtPath:(NSURL *)filePath {
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:filePath.absoluteString]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath.absoluteString error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}

- (void)createRecording:(Recording *)recording session:(NSString *)session {
    NSMutableArray *recordings = [self.data objectForKey:session];
    [recordings addObject:recording];
    [self save];
}

- (void)deleteRecording:(Recording *)recording session:(NSString *)session {
    [self deleteFileAtPath:[self urlForRecording:recording]];
    [(self.data)[session] removeObject:recording];
    [self save];
}

- (NSMutableArray *)getRecordingsForSession:(NSString *)session {
    NSMutableArray *recordings = [self.data objectForKey:session];
    return recordings ? recordings : [NSMutableArray array];
}

- (NSArray *)allSessions {
    return [self.data allKeys];
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.data] forKey:kSessionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)urlForRecording:(Recording *)recording {
    NSArray *pathComponents = @[[self documentsDirectory], recording.filePath];
    return [NSURL fileURLWithPathComponents:pathComponents];
}


@end
