//
//  CategoriesDatasource.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "CategoriesDatasource.h"
#import "WebApi.h"

@implementation CategoriesDatasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        cell.textLabel.textColor = [UIColor colorFromHex:@"666666"];
    }
    
    Topic *topic = [self.objects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = topic.name.capitalizedString;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
@end
