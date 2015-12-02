//
//  Session.h
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kSessionTitleKey;
extern NSString *const kSessionCreatedAtKey;
extern NSString *const kSessionRecordingsKey;

@class Recording;

@interface Session : NSObject <NSCoding>

+ (Session *)sessionFromDictionary:(NSDictionary *)dictionary;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, readonly) NSDate *createdAt;
@property (nonatomic, strong, readonly) NSDate *updatedAt;
@property (nonatomic, strong, readonly) NSMutableArray *recordings;

- (void)addNewRecording:(Recording *)recording;
- (void)deleteRecording:(Recording *)recording;

@end
