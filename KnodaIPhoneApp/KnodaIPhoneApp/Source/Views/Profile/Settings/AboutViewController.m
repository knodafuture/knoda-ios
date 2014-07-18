//
//  AboutViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 7/15/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AboutViewController.h"
#import "WebViewController.h"
#import <MessageUI/MessageUI.h>
#import "UINavigationBar+AppearanceUtils.h" 

@interface AboutViewController () <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ABOUT";
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    self.view.backgroundColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect frame = self.tableView.frame;
    frame.size = self.tableView.contentSize;
    self.tableView.frame = frame;
    
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"asd"];
    
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"asd"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        cell.textLabel.textColor = [UIColor colorFromHex:@"797979"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"Version";
    else if (indexPath.row == 1)
        cell.textLabel.text = @"View Terms of Service";
    else if (indexPath.row == 2)
        cell.textLabel.text = @"View Privacy Policy";
    else
        cell.textLabel.text = @"Contact Support";
    
    if (indexPath.row == 0) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor colorFromHex:@"797979"];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0];
        label.textAlignment = NSTextAlignmentRight;
        CGRect frame = label.frame;
        frame.size.width = 50;
        frame.size.height = cell.frame.size.height;
        frame.origin.x = cell.frame.size.width - frame.size.width - 10.0;
        label.frame = frame;
        [cell.contentView addSubview:label];
        label.text = [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/terms"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 2) {
        WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.com/privacy"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 3) {
        if ([MFMailComposeViewController canSendMail]) {
            [UINavigationBar setDefaultAppearance];
            MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
            [composeViewController setMailComposeDelegate:self];
            [composeViewController setToRecipients:@[@"support@knoda.com"]];
            [composeViewController setSubject:@"Knoda iOS Feedback"];
            [self presentViewController:composeViewController animated:YES completion:nil];
        } else {
            WebViewController *vc = [[WebViewController alloc] initWithURL:@"http://knoda.zendesk.com"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [UINavigationBar setCustomAppearance];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
