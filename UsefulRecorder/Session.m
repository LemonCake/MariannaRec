//
//  Session.m
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import "Session.h"

NSString * const kSessionTitleKey = @"kSessionTitleKey";
NSString * const kSessionCreatedAtKey = @"kSessionCreatedAtKey";
NSString * const kSessionRecordingsKey = @"kSessionRecordingsKey";

@interface Session()

@property (nonatomic, strong) NSMutableArray *recordings;
@property (nonatomic, strong) NSDate *createdAt;

@end

@implementation Session

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:kSessionTitleKey];
    [aCoder encodeObject:self.createdAt forKey:kSessionCreatedAtKey];
    [aCoder encodeObject:self.recordings forKey:kSessionRecordingsKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    
    if (self) {
        self.title = [aDecoder decodeObjectForKey:kSessionTitleKey];
        self.createdAt = [aDecoder decodeObjectForKey:kSessionCreatedAtKey];
        self.recordings = [aDecoder decodeObjectForKey:kSessionRecordingsKey];
    }
    
    return self;
}

+ (Session *)sessionFromDictionary:(NSDictionary *)dictionary {
    Session *session = [[Session alloc] init];
    
    if (session) {
        session.title = dictionary[kSessionTitleKey];
        session.createdAt = dictionary[kSessionCreatedAtKey];
        session.recordings = dictionary[kSessionRecordingsKey];
    }
    
    return session;
}

@end
