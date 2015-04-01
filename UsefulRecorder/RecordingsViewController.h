//
//  ViewController.h
//  UsefulRecorder
//
//  Created by Joshua Wu on 3/26/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Session;

@interface RecordingsViewController : UIViewController

+ (RecordingsViewController *)instantiateWithSession:(NSString *)session;

@property (nonatomic, strong) Session *session;

@end
