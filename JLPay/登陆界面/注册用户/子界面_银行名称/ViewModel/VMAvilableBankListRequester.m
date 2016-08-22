//
//  VMAvilableBankListRequester.m
//  JLPay
//
//  Created by jielian on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMAvilableBankListRequester.h"
#import "Define_Header.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>


@implementation VMAvilableBankListRequester

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedIndex = -1;
    }
    return self;
}


# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredBankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackBlue alpha:1];
        cell.textLabel.numberOfLines = 0;
    }
    return cell;
}

# pragma mask 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [[self.filteredBankList objectAtIndex:indexPath.row] objectForKey:BankListNodeBankName];
    if (indexPath.row == self.selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerView;
}


# pragma mask 3 private funcs


- (NSString*) urlString {
    return [NSString stringWithFormat:@"http://%@:%@/jlagent/Tblbanknamecode",
            [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
}



# pragma mask 4 getter

- (RACCommand *)cmdAviBankListRequesting {
    if (!_cmdAviBankListRequesting) {
        NameWeakSelf(wself);
        _cmdAviBankListRequesting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [subscriber sendNext:nil];
                
                [httpManager POST:[self urlString] parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                    NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                    NSString* message = [responseData objectForKey:@"message"];
                    if (code == 0) {
                        wself.bankListRequested = [[responseData objectForKey:@"banklist"] copy];
                        [wself.filteredBankList removeAllObjects];
                        [wself.filteredBankList addObjectsFromArray:wself.bankListRequested];
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [subscriber sendError:error];
                }];
                
                return nil;
            }] materialize];
        }];
    }
    return _cmdAviBankListRequesting;
}

- (NSMutableArray *)filteredBankList {
    if (!_filteredBankList) {
        _filteredBankList = [NSMutableArray array];
    }
    return _filteredBankList;
}

- (UIView *)headerView {
    if (!_headerView) {
        CGFloat inset = 5;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = 40;
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        
        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(inset * 2, inset, width - inset * 4, height - inset * 2)];
        textField.layer.cornerRadius = (height - inset * 2) * 0.5;
        textField.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1];
        UILabel* leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, height - inset * 2, height - inset * 2)];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        leftLabel.text = [NSString fontAwesomeIconStringForEnum:FASearch];
        leftLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:0.3];
        leftLabel.font = [UIFont fontAwesomeFontOfSize:[NSString resizeFontAtHeight:height - inset * 2 scale:0.6]];
        textField.leftView = leftLabel;
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.placeholder = @"搜索";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.textColor = [UIColor whiteColor];
        textField.font = [UIFont systemFontOfSize:15];
        
        [_headerView addSubview:textField];
        @weakify(self);
        
        [[[[textField.rac_textSignal skip:1] replayLast] delay:0.1] subscribeNext:^(NSString* key) {
            @strongify(self);
            NSMutableArray* newDisplayArray = [NSMutableArray array];
            for (NSDictionary* node in self.bankListRequested) {
                /* 这里的值可以用block在外面获取 */
                NSString* value = [node objectForKey:BankListNodeBankName];
                if ([value containsString:key]) {
                    [newDisplayArray addObject:node];
                }
            }
            [self.filteredBankList removeAllObjects];
            if (key && key.length > 0) {
                [self.filteredBankList addObjectsFromArray:newDisplayArray];
            } else {
                [self.filteredBankList addObjectsFromArray:self.bankListRequested];
            }
            
            if (self.filterKeyInputedBlock) {
                self.filterKeyInputedBlock();
            }
        }];
    }
    return _headerView;
}

@end
