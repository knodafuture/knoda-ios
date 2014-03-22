//
//  InvitationSearchView.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/20/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class User;
@class Contact;
@protocol InvitationSearchViewDelegate <NSObject>

- (void)invitationSearchViewDidSelectKnodaUser:(User *)user;
- (void)invitationSearchViewDidSelectContact:(Contact *)contact withEmail:(NSString *)email;
- (void)invitationSearchViewDidSelectContact:(Contact *)contact withPhoneNumber:(NSString *)phoneNumber;

@end

@interface InvitationSearchView : UIView

@property (weak, nonatomic) id<InvitationSearchViewDelegate> delegate;

- (id)initWithDelegate:(id<InvitationSearchViewDelegate>)delegate;

@end
