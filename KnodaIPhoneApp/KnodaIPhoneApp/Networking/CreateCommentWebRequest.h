//
//  CreateCommentWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@class Comment;
@interface CreateCommentWebRequest : BaseWebRequest
- (id)initWithComment:(Comment *)comment;
@end
