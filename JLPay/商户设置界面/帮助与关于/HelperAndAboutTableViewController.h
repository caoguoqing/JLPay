//
//  HelperAndAboutTableViewController.h
//  JLPay
//
//  Created by jielian on 15/8/14.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelperAndAboutTableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* cellTitles;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndImages;
@property (nonatomic, strong) NSMutableDictionary* dictTitlesAndDatas;


@end
