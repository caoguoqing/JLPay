//
//  VMBankBranchListRequester.m
//  JLPay
//
//  Created by 冯金龙 on 16/7/19.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMBankBranchListRequester.h"
#import "Define_Header.h"
#import <AFNetworking.h>
#import <ReactiveCocoa.h>
#import "MBProgressHUD+CustomSate.h"

@implementation VMBankBranchListRequester

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectedIndex = -1;
    }
    return self;
}



# pragma mask 2 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredBankBranchList.count;
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
    cell.textLabel.text = [[self.filteredBankBranchList objectAtIndex:indexPath.row] objectForKey:BankBranchItemBankName];
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

- (NSString* ) urlString {
    if (TestOrProduce == 11) {
        return [NSString stringWithFormat:@"http://%@:%@/kftagent/Tblbankstlno",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    } else {
        return [NSString stringWithFormat:@"http://%@:%@/jlagent/Tblbankstlno",
                [PublicInformation getServerDomain], [PublicInformation getHTTPPort]];
    }
}

- (NSDictionary* ) httpParameters {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.bankCode forKey:BankBranchItemBankCode];
    [parameters setObject:self.province forKey:BankBranchItemProvinceName];
    [parameters setObject:self.city forKey:BankBranchItemCityName];
    return parameters;
}

# pragma mask 4 getter

- (RACCommand *)cmdBankBranchListRequesting {
    if (!_cmdBankBranchListRequesting) {
        @weakify(self);
        _cmdBankBranchListRequesting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];

                MBProgressHUD* progressHud = [MBProgressHUD showNormalWithText:nil andDetailText:nil];
                
                [httpManager POST:[self urlString] parameters:[self httpParameters] progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                    NSInteger code = [[responseData objectForKey:@"code"] integerValue];
                    NSString* message = [responseData objectForKey:@"message"];
                    @strongify(self);
                    [progressHud hide:YES];
                    if (code == 0) {
                        NSArray* bankBranchList = [responseData objectForKey:BankBranchItemsList];
                        if (bankBranchList && bankBranchList.count > 0) {
                            self.bankBranchListRequested = bankBranchList;
                            [self.filteredBankBranchList removeAllObjects];
                            [self.filteredBankBranchList addObjectsFromArray:self.bankBranchListRequested];
                            [subscriber sendCompleted];
                        } else {
                            [MBProgressHUD showFailWithText:@"查无数据" andDetailText:nil onCompletion:^{
                                [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:@"查无数据"]];
                            }];
                        }
                    } else {
                        [MBProgressHUD showFailWithText:@"加载失败" andDetailText:message onCompletion:^{
                            [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:message]];
                        }];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [progressHud hide:YES];
                    [MBProgressHUD showFailWithText:@"加载失败" andDetailText:[error localizedDescription] onCompletion:^{
                        [subscriber sendError:error];
                    }];
                }];
                
                return nil;
            }] materialize];
        }];
    }
    return _cmdBankBranchListRequesting;
}

- (NSMutableArray *)filteredBankBranchList {
    if (!_filteredBankBranchList) {
        _filteredBankBranchList = [NSMutableArray array];
    }
    return _filteredBankBranchList;
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
            for (NSDictionary* node in self.bankBranchListRequested) {
                /* 这里的值可以用block在外面获取 */
                NSString* value = [node objectForKey:BankBranchItemBankName];
                if ([value containsString:key]) {
                    [newDisplayArray addObject:node];
                }
            }
            [self.filteredBankBranchList removeAllObjects];
            if (key && key.length > 0) {
                [self.filteredBankBranchList addObjectsFromArray:newDisplayArray];
            } else {
                [self.filteredBankBranchList addObjectsFromArray:self.bankBranchListRequested];
            }
            
            if (self.filterKeyInputedBlock) {
                self.filterKeyInputedBlock();
            }
        }];
    }
    return _headerView;
}


@end
