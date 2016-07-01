//
//  TerminalSelectorVModel.m
//  JLPay
//
//  Created by jielian on 16/4/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "TerminalSelectorVModel.h"

@implementation TerminalSelectorVModel

# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.terminals && self.terminals.count > 0) {
        return self.terminals.count;
    } else {
        return 0;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
        UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        backView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.1];
        cell.selectedBackgroundView = backView;
    }
    
    cell.textLabel.text = [self.terminals objectAtIndex:indexPath.row];
    
    if ([cell.textLabel.text isEqualToString:self.selectedTerminal]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

# pragma mask 2 UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedTerminal = [self.terminals objectAtIndex:indexPath.row];
    [tableView reloadData];
}


# pragma mask 4 getter
- (NSArray *)terminals {
    if (!_terminals) {
        _terminals = [[MLoginSavedResource sharedLoginResource].terminalList copy];
    }
    return _terminals;
}
- (NSString *)selectedTerminal {
    if (!_selectedTerminal) {
        if (self.terminals && self.terminals.count > 0) {
            _selectedTerminal = [self.terminals objectAtIndex:0];
        }
    }
    return _selectedTerminal;
}

@end
