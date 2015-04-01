//
//  Recording.h
//  UsefulRecorder
//
//  Created by Joshua Wu on 3/26/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Recording : NSObject <NSCoding>

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) NSString *title;

@end
