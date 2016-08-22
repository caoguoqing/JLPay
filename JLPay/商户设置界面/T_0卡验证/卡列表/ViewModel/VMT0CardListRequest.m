//
//  VMT0CardListRequest.m
//  JLPay
//
//  Created by jielian on 16/7/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMT0CardListRequest.h"
#import <ReactiveCocoa.h>
#import "Define_Header.h"
#import <AFNetworking.h>
#import "MT0CardList.h"
#import "CardCheckListCell.h"


@implementation VMT0CardListRequest

# pragma mask 2 UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cardListReqested.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardCheckListCell* cardCell = [tableView dequeueReusableCellWithIdentifier:@"CardCheckListCell"];
    if (!cardCell) {
        cardCell = [[CardCheckListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CardCheckListCell"];
    }
    return cardCell;
}

# pragma mask 2 UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* cardNode = [self.cardListReqested objectAtIndex:indexPath.row];
    CardCheckListCell* cardCell = (CardCheckListCell*)cell;
    
    NSString* cardNo = [cardNode objectForKey:kMT0CardListCardNo];
    cardCell.cardNoLabel.text = (cardNo.length > 13) ? ([PublicInformation cuttingOffCardNo:cardNo]) : (cardNo);
    
    NSString* userName = [cardNode objectForKey:kMT0CardListUserName];
    cardCell.cardCustName.text = [userName stringCuttingXingInRange:NSMakeRange(0, userName.length - 1)];
    
    NSInteger checkedFlag = [[cardNode objectForKey:kMT0CardListCheckFlag] integerValue];
    if (checkedFlag == 0) {
        cardCell.checkStateLabel.text = @"已验证";
        cardCell.checkStateLabel.textColor = [UIColor colorWithHex:HexColorTypeGreen alpha:1];
    }
    else if (checkedFlag == 1) {
        cardCell.checkStateLabel.text = @"正在验证";
        cardCell.checkStateLabel.textColor = [UIColor colorWithHex:HexColorTypeBlackGray alpha:1];
    }
    else {
        cardCell.checkStateLabel.text = [cardNode objectForKey:kMT0CardListRefuseReason];
        cardCell.checkStateLabel.textColor = [UIColor colorWithHex:HexColorTypeThemeRed alpha:1];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


# pragma mask 3 private funcs for http

- (NSString*) urlRequest {
    return [NSString stringWithFormat:@"http://%@:%@/jlagent/getT0CardInfo",
            [PublicInformation getServerDomain],
            [PublicInformation getHTTPPort]];
}

- (NSDictionary*) parametersRequest {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[PublicInformation returnBusiness] forKey:@"mchtNo"];
    return parameters;
}

- (NSArray*) sortedArrayOnDescBySource:(NSArray*)sourceArray {
    return [sourceArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString* checkFlag1 = [obj1 objectForKey:kMT0CardListCheckFlag];
        NSString* checkFlag2 = [obj2 objectForKey:kMT0CardListCheckFlag];
        return [checkFlag1 compare:checkFlag2] == NSOrderedAscending; /* 降序 */
    }];
}


# pragma mask 4 getter

- (RACCommand *)cmdRequesting {
    @weakify(self);
    if (!_cmdRequesting) {
        _cmdRequesting = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                @strongify(self);
                [subscriber sendNext:nil];
                AFHTTPSessionManager* httpManager = [AFHTTPSessionManager manager];
                httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
                
                [httpManager POST:[self urlRequest] parameters:[self parametersRequest] progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    NSDictionary* responseData = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
                    NSInteger responseCode = [[responseData objectForKey:@"code"] integerValue];
                    NSString* responseMessage = [responseData objectForKey:@"message"];
                    if (responseCode == 0) {
                        @strongify(self);
                        self.cardListReqested = [self sortedArrayOnDescBySource:[responseData objectForKey:@"cardList"]];
                        [subscriber sendCompleted];
                    } else {
                        [subscriber sendError:[NSError errorWithDomain:@"" code:99 localizedDescription:responseMessage]];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    [subscriber sendError:error];
                }];
                
                return nil;
            }] replayLast] materialize];
        }];
    }
    return _cmdRequesting;
}


@end
