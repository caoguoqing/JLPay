//
//  VMForT0UploadTBV.m
//  JLPay
//
//  Created by jielian on 16/7/13.
//  Copyright © 2016年 ShenzhenJielian. All rights reserved.
//

#import "VMForT0UploadTBV.h"
#import <ReactiveCocoa.h>
#import "SU_PhotoPickedTBVCell.h"
#import "SU_TextInputTBVCell.h"
#import "Define_Header.h"
#import "T0CardUploadViewController.h"


@implementation VMForT0UploadTBV



# pragma mask 2 UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.items.T0CUpload_items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.items.T0CUpload_items objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = [self cellIdentifierAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [self cellMadeByIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray* imgInfos = [self.items.T0CUpload_items objectAtIndex:section];
    MT0UploadItem* imgItem = [imgInfos firstObject];
    NSString* cellIdentifier = [self cellIdentifierAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return ([cellIdentifier isEqualToString:@"imagePickedCell"]) ? (imgItem.placeHolder) : (nil);
}

# pragma mask 2 UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([[self cellIdentifierAtIndexPath:indexPath] isEqualToString:@"imagePickedCell"]) ? (200) : (tableView.rowHeight);
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = [self cellIdentifierAtIndexPath:indexPath];
    MT0UploadItem* item = [self itemAtIndexPath:indexPath];
    
    if ([cellIdentifier isEqualToString:@"cardTypeCell"]) {
        cell.textLabel.text = item.itemTitle;
        cell.detailTextLabel.text = (item.cardType == MT0UploadCardTypeCredit) ? (@"信用卡") : (@"储蓄卡");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /* 绑定 */
        RAC(self, cardType) = [[RACObserve(item, cardType) map:^id(NSNumber* type) {
            return [NSString stringWithFormat:@"%d", type.integerValue];
        }] takeUntil:cell.rac_prepareForReuseSignal];
    }
    else if ([cellIdentifier isEqualToString:@"textInputCell"]) {
        SU_TextInputTBVCell* textFieldCell = (SU_TextInputTBVCell*)cell;
        textFieldCell.textLabel.text = item.itemTitle;
        textFieldCell.textField.placeholder = item.placeHolder;
        textFieldCell.textField.text = (item.inputed)?(item.textInputed):(nil);
        textFieldCell.textField.font = [UIFont systemFontOfSize:14];
        textFieldCell.textField.delegate = self;
        /* 绑定 */
        RAC(item, inputed) = [[RACObserve(textFieldCell.textField, text) map:^id(NSString* text) {
            return (text && text.length > 0) ? (@YES) : (@NO);
        }] takeUntil:textFieldCell.rac_prepareForReuseSignal];
        RAC(item, textInputed) = [textFieldCell.textField.rac_textSignal takeUntil:textFieldCell.rac_prepareForReuseSignal];
        
        if ([item.itemTitle isEqualToString:@"卡号"]) {
            RAC(self, cardNo) = [RACObserve(item, textInputed) takeUntil:textFieldCell.rac_prepareForReuseSignal];
        }
        else if ([item.itemTitle isEqualToString:@"持卡人"]) {
            RAC(self, userName) = [RACObserve(item, textInputed) takeUntil:textFieldCell.rac_prepareForReuseSignal];
        }
        else if ([item.itemTitle isEqualToString:@"身份证号"]) {
            RAC(self, userId) = [RACObserve(item, textInputed) takeUntil:textFieldCell.rac_prepareForReuseSignal];
        }
        else if ([item.itemTitle isEqualToString:@"手机号"]) {
            RAC(self, mobilePhone) = [RACObserve(item, textInputed) takeUntil:textFieldCell.rac_prepareForReuseSignal];
        }

    }
    else {
        SU_PhotoPickedTBVCell* imagePickedCell = (SU_PhotoPickedTBVCell*)cell;
        imagePickedCell.imgViewPicked.image = item.imgPicked;
        /* 绑定 */
        RAC(self, imagePicked) = [RACObserve(item, imgPicked) takeUntil:imagePickedCell.rac_prepareForReuseSignal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MT0UploadItem* item = [self itemAtIndexPath:indexPath];

    NSString* cellIdentifier = [self cellIdentifierAtIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:@"cardTypeCell"]) {
        [UIAlertController showActSheetWithTitle:@"请选择银行卡类型" message:nil target:self.superVC clickedHandle:^(UIAlertAction *action) {
            if ([action.title isEqualToString:@"储蓄卡"]) {
                item.cardType = MT0UploadCardTypeDebit;
                [tableView reloadData];
            }
            else if ([action.title isEqualToString:@"信用卡"]) {
                item.cardType = MT0UploadCardTypeCredit;
                [tableView reloadData];
            }
        } buttons:@{@(UIAlertActionStyleDefault):@"信用卡"},@{@(UIAlertActionStyleDefault):@"储蓄卡"},@{@(UIAlertActionStyleCancel):@"取消"}, nil];
    }
    else if ([cellIdentifier isEqualToString:@"imagePickedCell"]) {
        /* 区分拍照和显示 */
        if (item.inputed) {
            [UIAlertController showActSheetWithTitle:@"请选择" message:@"" target:self.superVC clickedHandle:^(UIAlertAction* action) {
                if ([action.title isEqualToString:@"查看大图"]) {
                    self.photoBrowser = [[VMSignUpPhotoBrowser alloc] initWithPhoto:item.imgPicked];
                    self.photoBrowser.superVC = self.superVC;
                    [self.photoBrowser showWithDone:^{
                        
                    } orDelete:^(NSInteger index) {
                        item.inputed = NO;
                        item.imgPicked = nil;
                        [tableView reloadData];
                    }];
                }
                else if ([action.title isEqualToString:@"重新拍照"]) {
                    self.photoPicker.superVC = self.superVC;
                    [self.photoPicker.sigPhotoPicking subscribeNext:^(UIImage* imagePicked) {
                        if (imagePicked) {
                            item.inputed = YES;
                            item.imgPicked = imagePicked;
                            [tableView reloadData];
                        }
                    }];
                }
            } buttons:@{@(UIAlertActionStyleCancel):@"取消"}, @{@(UIAlertActionStyleDefault):@"查看大图"}, @{@(UIAlertActionStyleDestructive):@"重新拍照"}, nil];
        } else {
            self.photoPicker.superVC = self.superVC;
            [self.photoPicker.sigPhotoPicking subscribeNext:^(UIImage* imagePicked) {
                if (imagePicked) {
                    item.inputed = YES;
                    item.imgPicked = imagePicked;
                    [tableView reloadData];
                }
            }];
        }

    }
    else {
        SU_TextInputTBVCell* textFieldCell = [tableView cellForRowAtIndexPath:indexPath];
        [textFieldCell.textField becomeFirstResponder];
    }
}


# pragma mask 2 UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    ((T0CardUploadViewController*)self.superVC).inputedCell = (UITableViewCell*)[textField superview];
    return YES;
}



# pragma mask 3 private funcs for dataSource

- (NSString*) cellIdentifierAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.section == 0) {
        return @"cardTypeCell";
    }
    else if (indexPath.section == 1) {
        return @"textInputCell";
    }
    else {
        return @"imagePickedCell";
    }
}

- (UITableViewCell*) cellMadeByIdentifier:(NSString*)cellIdentifier {
    UITableViewCell* cell = nil;
    if ([cellIdentifier isEqualToString:@"cardTypeCell"]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    else if ([cellIdentifier isEqualToString:@"textInputCell"]) {
        cell = [[SU_TextInputTBVCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    else {
        cell = [[SU_PhotoPickedTBVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (MT0UploadItem*) itemAtIndexPath:(NSIndexPath*)indexPath {
    return [[self.items.T0CUpload_items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

# pragma mask 4 getter

- (MT0CardUploadItems *)items {
    if (!_items) {
        _items = [[MT0CardUploadItems alloc] init];
    }
    return _items;
}

- (VMSignUpPhotoPicker *)photoPicker {
    if (!_photoPicker) {
        _photoPicker = [[VMSignUpPhotoPicker alloc] initWithViewController:self.superVC];
    }
    return _photoPicker;
}


@end
