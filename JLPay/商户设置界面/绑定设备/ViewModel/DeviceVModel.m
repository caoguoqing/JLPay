//
//  DeviceVModel.m
//  JLPay
//
//  Created by jielian on 16/4/12.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "DeviceVModel.h"

@implementation DeviceVModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.enableWriteKey = NO;
        self.stateMessage = @"请打开MPOS蓝牙设备";
        RAC(self,connected) = RACObserve(self.deviceManager, connected);
    }
    return self;
}
- (void)dealloc {
    JLPrint(@"-=-=-=-=-=-= dealloc:: DeviceVModel =-=-=-=-=-=-");
    [self.deviceManager stopScanning];
    [self.deviceManager disconnectOnFinished:nil];
}

# pragma mask 1 public interface

// -- 1. 扫描设备
- (void) startScanningOnDiscovered:(void (^) (void))discoveredPeripheral {
    self.stateMessage = @"开始扫描设备...";
    if (self.selectedPeripheral) self.selectedPeripheral = nil;
    NameWeakSelf(wself);
    [self.deviceManager startScanningOnDiscovered:^(CBPeripheral *peripheral) {
        BOOL contains = NO;
        for (CBPeripheral* innerPeripheral in wself.deviceList) {
            if ([innerPeripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                contains = YES;
                break;
            }
        }
        if (!contains) {            
            [wself.deviceList addObject:peripheral];
            if (discoveredPeripheral) discoveredPeripheral();
        }
    }];
}

// -- 2. 关闭扫描
- (void) stopScanning {
    [self.deviceList removeAllObjects];
    [self.deviceManager stopScanning];
}


// -- 3. 链接设备
- (void) conntectDeviceOnConnected:(void (^) (NSString* SNVersion))connectedSNVersion
                           onError:(void (^) (NSError* error))errorBlock
{
    self.stateMessage = @"正在连接设备...";
    NameWeakSelf(wself);
    [self.deviceManager connectPeripheral:self.selectedPeripheral onConnected:^(NSString *SNVersion) {
        wself.stateMessage = @"设备已连接,请点击'绑定'!";
        wself.enableWriteKey = YES;
        if (connectedSNVersion) connectedSNVersion(SNVersion);
    } onError:^(NSError *error) {
        wself.stateMessage = [NSString stringWithFormat:@"设备连接失败[%@]!",[error localizedDescription]];
        if (errorBlock) errorBlock(error);
    }];
}

// -- 4. 断开连接
- (void) disconnectDeviceOnFinished:(void (^) (void))finished {
    self.enableWriteKey = NO;
    [self.deviceManager disconnectOnFinished:^{
        if (finished) finished();
    }];
}

// -- 5. 写主密钥
- (void) writeMainKey:(NSString*)mainKey
           onFinished:(void (^) (void))finishedBlock
              onError:(void (^) (NSError* error))errorBlock
{
    self.stateMessage = @"正在写主密钥...";
    NameWeakSelf(wself);
    JLPrint(@"------正在写的主密钥:[%@]", mainKey);
    [self.deviceManager writeMainKey:mainKey onFinished:^{
        wself.stateMessage = @"写主密钥成功!";
        if (finishedBlock) finishedBlock();
    } onError:^(NSError *error) {
        wself.stateMessage = @"写主密钥失败!";
        if (errorBlock) errorBlock(error);
    }];
}

// -- 6. 写工作密钥
- (void) writeWorkKey:(NSString*)workKey
           onFinished:(void (^) (void))finishedBlock
              onError:(void (^) (NSError* error))errorBlock
{
    self.stateMessage = @"正在写工作密钥...";
    NameWeakSelf(wself);
    [self.deviceManager writeWorkKey:workKey onFinished:^{
        wself.stateMessage = @"写工作密钥成功!";
        wself.enableWriteKey = NO;
        if (finishedBlock) finishedBlock();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            wself.stateMessage = @"设备绑定成功!!";
        });
    } onError:^(NSError *error) {
        wself.stateMessage = @"写工作密钥失败!";
        if (errorBlock) errorBlock(error);
    }];
}




# pragma mask 2 UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"cellIdentifier";
    BTDeviceChooseCell* cell = (BTDeviceChooseCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BTDeviceChooseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.separatorInset = UIEdgeInsetsZero;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
        UIView* backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        backView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        cell.selectedBackgroundView = backView;
    }
    CBPeripheral* peripheral = [self.deviceList objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    if (self.selectedPeripheral && [self.selectedPeripheral.name isEqualToString:peripheral.name]) {
        [cell.checkView setChecked:YES];
    } else {
        [cell.checkView setChecked:NO];
    }
    return cell;
}


# pragma mask 2 UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedPeripheral = [self.deviceList objectAtIndex:indexPath.row];
    self.stateMessage = @"已选择设备,正在连接...";
    [tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [tableView sectionHeaderHeight];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = @"正在扫描蓝牙设备";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentLeft;
    
    UIActivityIndicatorView* activitor = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activitor startAnimating];
    
    [headerView addSubview:activitor];
    [headerView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([label.text resizeAtHeight:height scale:0.4].width + 4);
        make.height.mas_equalTo(height);
        make.centerX.equalTo(headerView.mas_centerX);
        make.centerY.equalTo(headerView.mas_centerY);
        label.font = [UIFont systemFontOfSize:[label.text resizeFontAtHeight:height scale:0.4]];
    }];
    [activitor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.centerY.equalTo(label.mas_centerY);
        make.right.equalTo(label.mas_left);
    }];
    
    return headerView;
}




# pragma mask 4 getter
- (DeviceManager *)deviceManager {
    if (!_deviceManager) {
        _deviceManager = [DeviceManager sharedInstance];
    }
    return _deviceManager;
}
- (NSMutableArray *)deviceList {
    if (!_deviceList) {
        _deviceList = [NSMutableArray array];
    }
    return _deviceList;
}

@end
