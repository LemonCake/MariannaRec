//
//  SessionCell.h
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SessionCellDelegate;

@class Session;

@interface SessionCell : UITableViewCell

- (void)configureWithSession:(Session *)session;

@property (nonatomic, assign) id<SessionCellDelegate>delegate;

@end

@protocol SessionCellDelegate <NSObject>

@optional

- (void)sessionCell:(SessionCell *)sessionCell onEdit:(Session *)session;

@end
