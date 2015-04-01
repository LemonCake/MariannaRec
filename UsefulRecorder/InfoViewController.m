//
//  InfoViewController.m
//  MariannaRec
//
//  Created by Joshua Wu on 12/4/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "InfoViewController.h"
#import <MessageUI/MessageUI.h>

@interface InfoViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) MFMailComposeViewController *mailComposer;

@end

@implementation InfoViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

+ (InfoViewController *)instantiate {
    UIStoryboard *storyboard = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?
    [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] :
    [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    
    InfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InfoViewController"];
    return vc;
}

- (IBAction)onFacebook:(id)sender {
    NSString *fbLink = @"https://www.facebook.com/pages/Mariannaland/429599327130646";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fbLink]];
}

- (IBAction)onEmail:(id)sender {
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    // Email Subject
    NSString *emailTitle = @"Hello!";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"sing@mariannaland.com"];
    
    self.mailComposer = [[MFMailComposeViewController alloc] init];
    self.mailComposer.mailComposeDelegate = self;
    [self.mailComposer setSubject:emailTitle];
    [self.mailComposer setMessageBody:messageBody isHTML:NO];
    [self.mailComposer setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:self.mailComposer animated:YES completion:NULL];
}

- (IBAction)onClose:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSing:(id)sender {
    NSString *singAppLink = @"http://api.smule.com/v2/redirect/eyJ3ZWJVcmwiOiJodHRwOi8vZ2VvcmlvdC5jby8zaEhrIiwibW9iaWxlVXJsIjoiaHR0cDovL2dlb3Jpb3QuY28vM2hIayIsImNhbXBhaWduSWQiOjEyMzIsImFwcCI6IlNJTkcifQ==";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:singAppLink]];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
