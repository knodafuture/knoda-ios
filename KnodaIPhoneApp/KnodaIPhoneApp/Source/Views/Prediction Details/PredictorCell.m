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
}

- (IBAction)agreedUserClicked:(id)sender {
    [self.delegate predictorCellDidSelectUserWithUserId:self.agreedUser.userId];
}

- (IBAction)disagreedUserClicked:(id)sender {
    [self.delegate predictorCellDidSelectUserWithUserId:self.disagreedUser.userId];
}

@end
