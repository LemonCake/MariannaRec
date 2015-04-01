//
//  SessionCell.m
//  MariannaRec
//
//  Created by Joshua Wu on 4/1/15.
//  Copyright (c) 2015 Joshua Wu. All rights reserved.
//

#import "SessionCell.h"
#import "Session.h"

@interface SessionCell()

@property (strong, nonatomic) Session *session;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation SessionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configureWithSession:(Session *)session {
    self.session = session;
    self.titleLabel.text = session.title;
}

- (IBAction)onEdit:(id)sender {
    if ([self.delegate respondsToSelector:@selector(sessionCell:onEdit:)]) {
        [self.delegate sessionCell:self onEdit:self.session];
    }
}

@end
