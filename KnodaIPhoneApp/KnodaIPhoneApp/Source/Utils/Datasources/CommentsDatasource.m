//
//  CommentsDatasource.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CommentsDatasource.h"
#import "Comment+Utils.h"
#import "CommentCell.h"

@implementation CommentsDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    Comment *comment = [self.objects objectAtIndex:indexPath.row];
    return [CommentCell heightForComment:comment];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CommentCell *cell = [CommentCell commentCellForTableView:tableView];
    
    Comment *comment = [self.objects objectAtIndex:indexPath.row];
    
    [cell fillWithComment:comment];
    
    return cell;
    
}




@end
