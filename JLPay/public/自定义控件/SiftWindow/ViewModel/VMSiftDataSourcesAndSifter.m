//
//  VMSiftDataSourcesAndSifter.m
//  JLPay
//
//  Created by jielian on 16/6/2.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMSiftDataSourcesAndSifter.h"
#import "Define_Header.h"
#import <ReactiveCocoa.h>
#import "SiftTBVMainCell.h"


@implementation VMSiftDataSourcesAndSifter

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mainSelected = -1;
        self.assistantSelected = -1;
        [self addKVOs];
    }
    return self;
}

- (void) addKVOs {
    @weakify(self);
    
    [RACObserve(self, mainDataSourcesList) subscribeNext:^(NSArray* list) {
        @strongify(self);
        [self.indexListSifted removeAllObjects];
        for (int i = 0; i < list.count; i ++) {
            [self.indexListSifted addObject:[NSMutableArray array]];
        }
    }];
}

- (void) clearsSiftedIndexs {
    for (NSMutableArray* siftedIndex in self.indexListSifted) {
        if (siftedIndex && siftedIndex.count > 0) {
            [siftedIndex removeAllObjects];
        }
    }
}

# pragma mask 2 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == TagOfSiftTBVMain) {
        if (self.mainDataSourcesList) {
            return self.mainDataSourcesList.count;
        } else {
            return 0;
        }
    } else {
        if (self.mainSelected >= 0) {
            return [[self.assistantDataSourcesList objectAtIndex:self.mainSelected] count];
        } else {
            return 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
    NSString* mainIdentifier = @"main";
    NSString* assistantIdentifier = @"assistant";
    UITableViewCell* cell = nil;   
    
    
    if (tableView.tag == TagOfSiftTBVMain) {
        SiftTBVMainCell* mainCell = [tableView dequeueReusableCellWithIdentifier:mainIdentifier];
        if (!mainCell) {
            mainCell = [[SiftTBVMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:mainIdentifier];
        }
        mainCell.textLabel.text = [self.mainDataSourcesList objectAtIndex:indexPath.row];
        mainCell.textLabel.font = [UIFont boldSystemFontOfSize:[@"xx" resizeFontAtHeight:rect.size.height scale:0.4]];
        if ([self.indexListSifted[indexPath.row] count] > 0) {
            mainCell.siftCountLabel.text = [NSString stringWithFormat:@"%d", [[self.indexListSifted objectAtIndex:indexPath.row] count]];
            mainCell.siftCountLabel.hidden = NO;
        } else {
            mainCell.siftCountLabel.hidden = YES;
        }
        mainCell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];

        
        if (indexPath.row == self.mainSelected) {
            mainCell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        } else {
            mainCell.backgroundColor = [UIColor clearColor];
        }
        
        cell = mainCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:assistantIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:assistantIdentifier];
            cell.backgroundColor = [UIColor clearColor];
        }
        
        NSArray* datas = [self.assistantDataSourcesList objectAtIndex:((self.mainSelected >= 0)?(self.mainSelected):(0))];
        cell.textLabel.text = [datas objectAtIndex:indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        
        NSIndexPath* assisIndexP = [NSIndexPath indexPathForRow:indexPath.row inSection:self.mainSelected];
        if ([self isSelectedOrNotAtIndexPath:assisIndexP]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:[@"xx" resizeFontAtHeight:rect.size.height scale:0.36]];

    }
    
    
    return cell;
}

# pragma mask 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == TagOfSiftTBVMain) {
        self.mainSelected = indexPath.row;
    } else {
        self.assistantSelected = indexPath.row;
        NSIndexPath* assisSelectedIndexP = [NSIndexPath indexPathForRow:indexPath.row inSection:self.mainSelected];
        if ([self isSelectedOrNotAtIndexPath:assisSelectedIndexP]) {
            [self deleteUnselecedIndexPath:assisSelectedIndexP];
        } else {
            [self insetIntoBySelectedIndexPath:assisSelectedIndexP];
        }
    }
    [tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


# pragma mask 3 选择或取消选择cell时的选择集更新

/* 先判断是否在选项集 */
- (BOOL) isSelectedOrNotAtIndexPath:(NSIndexPath*)indexPath {
    NSArray* mainListItem = (self.indexListSifted.count > 0)?([self.indexListSifted objectAtIndex:indexPath.section]):([NSArray array]);
    BOOL isSelected = NO;
    for (NSNumber* value in mainListItem) {
        if (value.integerValue == indexPath.row) {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}

/* 添加选项 */
- (void) insetIntoBySelectedIndexPath:(NSIndexPath*)indexPath {
    NSMutableArray* mainListItem = [self.indexListSifted objectAtIndex:indexPath.section];
    [mainListItem addObject:@(indexPath.row)];
}
/* 删除选项 */
- (void) deleteUnselecedIndexPath:(NSIndexPath*)indexPath {
    NSNumber* unselectedItem = nil;
    NSMutableArray* mainListItem = [self.indexListSifted objectAtIndex:indexPath.section];

    for (NSNumber* value in mainListItem) {
        if (value.integerValue == indexPath.row) {
            unselectedItem = value;
            break;
        }
    }
    
    [mainListItem removeObject:unselectedItem];
}

# pragma mask 4 getter 
- (NSMutableArray *)indexListSifted {
    if (!_indexListSifted) {
        _indexListSifted = [NSMutableArray array];
        /* 这是一个二维数组，第二维是动态添加或删除的序号组 */
//        for (int i = 0; i < self.mainDataSourcesList.count; i++) {
//            [_indexListSifted addObject:[NSMutableArray array]];
//        }
    }
    return _indexListSifted;
}


@end
