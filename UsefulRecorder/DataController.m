//
//  DataController.m
//  UsefulRecorder
//
//  Created by Joshua Wu on 4/2/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "DataController.h"
#import "Recording.h"
#import "Session.h"

NSString *const kOldSessionsKey = @"sessions_and_recordings"; // version 1.0 key to migrate
NSString *const kSessionsDataKey = @"kSessionsDataKey";

@interface DataController()

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSSortDescriptor *sortDescriptor;
@property (nonatomic, assign) BOOL sortAsc;

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
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:self.sortAsc];
    
    self.data = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kSessionsDataKey]];
    
    if (!self.data) {
        self.data = [NSMutableArray array];
        [[NSUserDefaults standardUserDefaults] setObject:self.data forKey:kSessionsDataKey];
        [self save];
    }

    NSMutableDictionary *oldSessions = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kOldSessionsKey]];
    
    if (oldSessions) {
        for (NSString *key in oldSessions) {
            NSMutableArray *oldRecordings = oldSessions[key];
            
            NSDate *createdAt = [NSDate date];
            
            if (oldRecordings.count > 0 && ((Recording *)oldRecordings.firstObject).createdAt) {
                createdAt = ((Recording *)oldRecordings.firstObject).createdAt;
            }
            
            NSDictionary *configDictionary = @{kSessionTitleKey : key,
                                               kSessionRecordingsKey : oldRecordings,
                                               kSessionCreatedAtKey : createdAt};
            [self.data addObject:[Session sessionFromDictionary:configDictionary]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kOldSessionsKey];
        [self save];
    }

    // due to track deletion bug, prune tracks that don't exist anymore
    for (Session *session in self.data) {
        NSMutableArray *recordingToDelete = [NSMutableArray array];
        
        for (Recording *recording in session.recordings) {
            NSURL *filePath = [self urlForRecording:recording];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
                [self deleteFileAtPath:[self urlForRecording:recording]];
                [recordingToDelete addObject:recording];
            }
        }
        
        for (Recording *deleteRecording in recordingToDelete) {
            [session deleteRecording:deleteRecording];
        }
    }
    
    self.sortAsc = YES; // default to sort ascending
    [self sortByUpdatedAt];
}

- (void)createNewSession:(NSString *)session completion:(DataControllerCompletionBlock)completion {
    Session *newSession = [Session sessionFromDictionary:@{kSessionTitleKey : session,
                                                           kSessionCreatedAtKey : [NSDate date],
                                                           kSessionRecordingsKey : [NSMutableArray array]}];
    [self.data insertObject:newSession atIndex:0];
    [self save];
        
    if (completion) { completion(); }
}

- (void)deleteSession:(Session *)session {
    for (Recording *recording in session.recordings) {
        [self deleteFileAtPath:[self urlForRecording:recording]];
    }
    
    [self.data removeObject:session];
    [self save];
}

- (void)deleteFileAtPath:(NSURL *)filePath {
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:filePath.path]) {
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:filePath.path error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}

- (void)createRecording:(Recording *)recording session:(Session *)session {
    [session addNewRecording:recording];
    [self save];
}

- (void)deleteRecording:(Recording *)recording session:(Session *)session {
    [self deleteFileAtPath:[self urlForRecording:recording]];
    [session deleteRecording:recording];
    [self save];
}

- (void)renameSession:(Session *)session title:(NSString *)title {
    session.title = title;
    [self save];
}

- (void)renameTrack:(Recording *)recording title:(NSString *)title {
    recording.title = title;
    [self save];
}

- (NSArray *)allSessions {
    return self.data;
}

- (void)save {
    [self.data sortUsingDescriptors:@[self.sortDescriptor]];
     
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.data] forKey:kSessionsDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL *)urlForRecording:(Recording *)recording {
    NSArray *pathComponents = @[[self documentsDirectory], recording.filePath];
    return [NSURL fileURLWithPathComponents:pathComponents];
}

#pragma mark - sorting order

- (void)sortByCreatedAt {
    if (self.sortDescriptor && [self.sortDescriptor.key isEqualToString:@"createdAt"]) {
        self.sortAsc = !self.sortAsc;
    }
    
    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:self.sortAsc];
    [self.data sortUsingDescriptors:@[self.sortDescriptor]];
}

- (void)sortByUpdatedAt {
    if (self.sortDescriptor && [self.sortDescriptor.key isEqualToString:@"updatedAt"]) {
        self.sortAsc = !self.sortAsc;
    }

    self.sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:self.sortAsc];
    [self.data sortUsingDescriptors:@[self.sortDescriptor]];

}

@end
