//
//  MySQLiteManager.m
//  TestForSQLite
//
//  Created by jielian on 15/8/10.
//  Copyright (c) 2015年 ShenzhenJielian. All rights reserved.
//

#import "MySQLiteManager.h"
#import <errno.h>

@interface MySQLiteManager()

@end

@implementation MySQLiteManager

+ (MySQLiteManager *)SQLiteManagerWithDBFile:(NSString *)DBFile {
    if (_SQLiteManager == nil) {
        _SQLiteManager = [[MySQLiteManager alloc] initWithDBFile:DBFile];
    }
    return _SQLiteManager;
}


/*
 * 插入数据
 */
- (BOOL)insertDataWithSQLString:(NSString *)SQLString {
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString* dataPath = [documentPaths objectAtIndex:0];

    const char* cdataPath = [dataPath UTF8String];
    BOOL result = NO;
    if (sqlite3_open(cdataPath, &dataBase) == SQLITE_OK) {
        const char* insert_stmt = [SQLString UTF8String];
        if (sqlite3_prepare_v2(dataBase, insert_stmt, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_DONE) {
                result = YES;
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(dataBase);
    return result;
}

/*
 * 查询数据
 */
- (NSArray *)selectedDatasWithSQLString:(NSString *)SQLString {
    NSMutableArray* selectedDatas = [[NSMutableArray alloc] init];
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString* dataPath = [documentPaths objectAtIndex:0];
    const char* cdataPath = [dataPath UTF8String];
    // 打开db文件
    if (sqlite3_open(cdataPath, &dataBase) == SQLITE_OK) {
        const char* select_stmt = [SQLString UTF8String];
        // 准备好语句缓冲区--数据缓存到游标
        if (sqlite3_prepare_v2(dataBase, select_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // 逐条扫描游标

            int rowsCount = 0;
            int stateOfSQLite = SQLITE_ROW;
            while (stateOfSQLite) {
                // 从游标中查出一条数据
                stateOfSQLite = sqlite3_step(statement);
                if (stateOfSQLite != SQLITE_ROW) {
                    break;
                }

                // 拆分数据,封装到dic
                int columCount = sqlite3_column_count(statement);
                rowsCount++;
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                for (int i = 0; i < columCount; i++) {
                    const unsigned char* column = sqlite3_column_text(statement, i);
                    const char* name = sqlite3_column_name(statement, i);
                    [dict setValue:[NSString stringWithCString:(const char*)column encoding:NSUTF8StringEncoding]
                            forKey:[NSString stringWithCString:(const char*)name encoding:NSUTF8StringEncoding]];
                }
                // 将拆分的数据添加到数组
                [selectedDatas addObject:dict];
            }
            if (stateOfSQLite != SQLITE_DONE) {
                NSLog(@"查询异常:sqlite_state=[%d],清空已查询数据",stateOfSQLite);
                [selectedDatas removeAllObjects];
            } else {
            }
        }
    } else {
        NSLog(@"打开数据库文件失败:[%s]",strerror(errno));
    }
    sqlite3_finalize(statement);
    sqlite3_close(dataBase);
    return selectedDatas;
}



// 初始化 manager: 移动db文件到沙盒
- (instancetype)initWithDBFile:(NSString *)DBFile {
    self = [super init];
    if (self) {
        NSFileManager* fileManager = [[NSFileManager alloc] init];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
        NSString* documentDirectory = [paths objectAtIndex:0];
        
        NSString* dataBasePath = [documentDirectory stringByAppendingPathComponent:DBFile];
        if (![fileManager fileExistsAtPath:dataBasePath isDirectory:nil]) {
            // 不存在db文件就拷贝文件到沙盒
            NSString* sourceFile = [[NSBundle mainBundle] pathForResource:[DBFile substringToIndex:[DBFile rangeOfString:@"."].location] ofType:@"db"];

            if ([fileManager fileExistsAtPath:sourceFile]) {
                NSError* error;
                [fileManager copyItemAtPath:sourceFile toPath:documentDirectory error:&error];
//                BOOL copied = [fileManager copyItemAtPath:sourceFile toPath:documentDirectory error:&error];
//                if (copied) {
//                    NSLog(@"拷贝db文件到沙盒成功");
//                } else {
//                    NSLog(@"拷贝db文件到沙盒失败:[%@]",error);
//                }
            }
        } else {
//            NSLog(@"db文件[%@]已经存在",dataBasePath);
        }
    }
    return self;
}

@end
