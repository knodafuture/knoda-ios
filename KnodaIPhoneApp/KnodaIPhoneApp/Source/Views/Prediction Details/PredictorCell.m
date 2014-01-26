//
//  PredictorCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictorCell.h"
#import "TallyUser.h"

static UINib *nib;

CGFloat PredictorCellHeight = 22.0;

@interface PredictorCell ()
@property (weak, nonatomic) IBOutlet UILabel *agreedUserName;
@property (weak, nonatomic) IBOutlet UILabel *disagreedUserName;

@property (strong, nonatomic) TallyUser *agreedUser;
@property (strong, nonatomic) TallyUser *disagreedUser;

@property (weak, nonatomic) IBOutlet UIImageView *agreedVerifiedCheckmark;
@property (weak, nonatomic) IBOutlet UIImageView *disagreedVerifiedCheckmark;

@end


@implementation PredictorCell

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictorCell" bundle:[NSBundle mainBundle]];
}

+ (PredictorCell *)predictorCellForTableView:(UITableView *)tableView {
    PredictorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictorCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

- (void)setAgreedUser:(TallyUser *)agreedUser andDisagreedUser:(TallyUser *)disagreedUser {
    self.agreedUser = agreedUser;
    self.agreedUserName.text = agreedUser.username;
    
    self.disagreedUser = disagreedUser;
    self.disagreedUserName.text = disagreedUser.username;
    
    
    if (!agreedUser.verifiedAccount)
        self.agreedVerifiedCheckmark.hidden = YES;
    else {
        self.agreedVerifiedCheckmark.hidden = NO;
        CGSize textSize = [self.agreedUserName sizeThatFits:self.agreedUserName.frame.size];
        
        CGRect frame = self.agreedVerifiedCheckmark.frame;
        frame.origin.x = self.agreedUserName.frame.origin.x + textSize.width + 5.0;
        self.agreedVerifiedCheckmark.frame = frame;
    }
    
    if (!disagreedUser.verifiedAccount)
        self.disagreedVerifiedCheckmark.hidden = YES;
    else {
        self.disagreedVerifiedCheckmark.hidden = NO;
        CGSize textSize = [self.disagreedUserName sizeThatFits:self.agreedUserName.frame.size];
        
        CGRect frame = self.disagreedVerifiedCheckmark.frame;
        frame.origin.x = self.disagreedUserName.frame.origin.x + textSize.width + 5.0;
        self.disagreedVerifiedCheckmark.frame = frame;
    }
    
}

- (IBAction)agreedUserClicked:(id)sender {
    [self.delegate predictorCellDidSelectUserWithUserId:self.agreedUser.userId];
}

- (IBAction)disagreedUserClicked:(id)sender {
    [self.delegate predictorCellDidSelectUserWithUserId:self.disagreedUser.userId];
}

@end
