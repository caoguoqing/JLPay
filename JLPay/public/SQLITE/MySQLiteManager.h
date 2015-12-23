//
//  MySQLiteManager.h
//  TestForSQLite
//
//  Created by jielian on 15/8/10.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


// 数据库文件 - 全国地名及代码
#define DBFILENAME_AREACODE             @"test.db"


/*
 * 使用第三方库 sqlite3
 * 1.初始化:使用准备好的db文件
 * 2.创建表
 * 3.DM语句
 * 4.
 */
@class MySQLiteManager;
static MySQLiteManager* _SQLiteManager = nil;
static sqlite3* dataBase = nil;
static sqlite3_stmt* statement = nil;
//static dispatch_once_t SQLdesp;

@interface MySQLiteManager : NSObject
// 使用db文件初始化 SQLiteManager
+(MySQLiteManager*) SQLiteManagerWithDBFile:(NSString*)DBFile;

// 插入数据
- (BOOL) insertDataWithSQLString:(NSString*)SQLString;
// 查询数据
- (NSArray*) selectedDatasWithSQLString:(NSString*)SQLString;
@end
