//
//  Recording.m
//  UsefulRecorder
//
//  Created by Joshua Wu on 3/26/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "Recording.h"

@implementation Recording

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    
    if (self) {
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
        self.createdAt = [aDecoder decodeObjectForKey:@"createdAt"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    
    return self;
}

@end
