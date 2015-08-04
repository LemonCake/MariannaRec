//
//  SessionsViewController.m
//  UsefulRecorder
//
//  Created by Joshua Wu on 3/28/14.
//  Copyright (c) 2014 Joshua Wu. All rights reserved.
//

#import "SessionsViewController.h"
#import "RecordingsViewController.h"
#import "DataController.h"
#import "InfoViewController.h"
#import "UIAlertView+Blocks.h"
#import "SessionCell.h"
#import "Session.h"

@interface SessionsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SessionCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SessionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods

- (IBAction)onInfo:(id)sender {
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[InfoViewController instantiate]];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataController sharedInstance].allSessions.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SESSION_CELL = @"SESSION_CELL";
    static NSString *NEW_SESSION_CELL = @"NEW_SESSION_CELL";
    

    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NEW_SESSION_CELL];
        cell.textLabel.text = @"Start new session...";
        return cell;
    } else {
        SessionCell *cell = [tableView dequeueReusableCellWithIdentifier:SESSION_CELL];
        [cell configureWithSession:[DataController sharedInstance].allSessions[(NSUInteger)indexPath.row - 1]];
        cell.delegate = self;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Enter session name"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Add", nil];
        
        av.alertViewStyle = UIAlertViewStylePlainTextInput;

        MagicBlockWeakSelf weakSelf = self;

        av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == alertView.firstOtherButtonIndex) {
                [[DataController sharedInstance] createNewSession:[alertView textFieldAtIndex:0].text
                                                       completion:^(void) {
                    [weakSelf.tableView reloadData];
                }];
            }
        };
        
        [av show];
    } else {
        RecordingsViewController *rvc = [RecordingsViewController instantiateWithSession:[DataController sharedInstance].allSessions[indexPath.row - 1]];
        [self.navigationController presentViewController:rvc animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row > 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MagicBlockWeakSelf weakSelf = self;
        
        [UIAlertView showWithTitle:@"Are you sure?" message:@"This will delete all your recordings!" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[DataController sharedInstance] deleteSession:[DataController sharedInstance].allSessions[indexPath.row - 1]];
                [weakSelf.tableView reloadData];
            }
        }];
    }
}

#pragma mark - SessionCellDelegate methods

- (void)sessionCell:(SessionCell *)sessionCell onEdit:(Session *)session {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Rename session"
                                                 message:@""
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Rename", nil];
    
    av.alertViewStyle = UIAlertViewStylePlainTextInput;
    [av textFieldAtIndex:0].text = session.title;
    
    MagicBlockWeakSelf weakSelf = self;
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [[DataController sharedInstance] renameSession:session title:[alertView textFieldAtIndex:0].text];
            [weakSelf.tableView reloadData];
        }
    };
    
    [av show];
}

@end
