//
//  SessionCell.h
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSString *kSessionTitleKey;

@protocol SessionCellDelegate;

@interface SessionCell : UITableViewCell

@property (nonatomic, assign) id<SessionCellDelegate>delegate;

@end

@protocol SessionCellDelegate <NSObject>

@optional

- (void)sessionCellEdit:(SessionCell *)sessionCell;

@end
