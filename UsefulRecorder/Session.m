//
//  Session.m
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import "Session.h"

@interface Session()

@property (nonatomic, strong) NSMutableArray *recordings;

@end

@implementation Session

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.recordings forKey:@"filePath"];
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    
    if (self) {
        self.recordings = [aDecoder decodeObjectForKey:@"filePath"];
        self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    
    return self;
}

+ (Session *)sessionFromDictionary:(NSDictionary *)dictionary {
    Session *session = [[Session alloc] init];
    
    if (session) {
        session.title = dictionary[@"title"];
        session.createdAt = dictionary[@"createdAt"];
        session.recordings = dictionary[@"recordings"];
    }
    
    return session;
}

@end
