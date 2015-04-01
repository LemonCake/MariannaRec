//
//  SessionCell.m
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import "SessionCell.h"

const NSString *kSessionTitleKey = @"kSessionTitleKey";

@interface SessionCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SessionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configure:(NSDictionary *)config {
    self.titleLabel.text = config[kSessionTitleKey];
}

- (IBAction)onEdit:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sessionCellEdit:)]) {
        [self.delegate sessionCellEdit:self];
    }
}

@end
