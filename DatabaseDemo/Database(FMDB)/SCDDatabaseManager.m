//
//  SCDDatabaseManager.m
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/30.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "SCDDatabaseManager.h"

#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
static NSString *const kLastDatabaseVersionKey = @"lastDatabaseVersion";

@interface SCDDatabaseManager ()
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end

@implementation SCDDatabaseManager

#pragma mark - init
+ (SCDDatabaseManager *)sharedManager {
    static dispatch_once_t onceToken = 0;
    static SCDDatabaseManager *defaultManager = nil;

    dispatch_once(&onceToken, ^{
        defaultManager = [[self alloc] init];
    });

    return defaultManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDataBase];
    }

    return self;
}

#pragma mark - 初始化数据库
- (void)initDataBase {
    NSString *dbCachePath = [self DBPath];
    BOOL success = NO;

    NSString *appVersionBeforeUpgrade = [[NSUserDefaults standardUserDefaults] objectForKey:kLastDatabaseVersionKey];

    if (appVersionBeforeUpgrade == nil) {
        //上一版本没有数据库，执行建表操作

        // 采用预置DB的情况下，首次直接copy bundleDB
        if (![[NSFileManager defaultManager] fileExistsAtPath:dbCachePath]) {
            NSError *error = nil;
            success = [[NSFileManager defaultManager] copyItemAtPath:[self bundleDBPath] toPath:dbCachePath error:&error];
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:AppVersion forKey:kLastDatabaseVersionKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                NSAssert(0, @"copy database fail");
            }
        } else {
            // TODO:执行初始DB创建--creatTables
        }
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbCachePath];
    } else {
        // 升级数据表
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbCachePath];
        if ([AppVersion compare:appVersionBeforeUpgrade] == NSOrderedDescending) {
            // 版本号增加，进行数据库更新
            success = [self updateTablesFrom:appVersionBeforeUpgrade];
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:AppVersion forKey:kLastDatabaseVersionKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                // TODO:更新失败，drop所有数据表，重新构建数据库?
                NSAssert(0, @"update database fail");
            }
        } else if ([AppVersion compare:appVersionBeforeUpgrade] == NSOrderedAscending) {
            NSAssert(0, @"版本号降低，业务不会出现");
        } else {
            success = YES;
        }
    }
}

#pragma mark - update
/**
 *  更新数据库表结构或创建新表
 */
- (BOOL)updateTablesFrom:(NSString *)preVersion {
    // plist文件根结构为数组，应按照版本顺序添加更新sql语句
    NSString *sourcePath = [self updateDBPath];
    NSArray *sqlsForEachVersion = [[NSArray alloc] initWithContentsOfFile:sourcePath];
    __block BOOL success = NO;

    [sqlsForEachVersion enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop1) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *versionSqlsDict = obj;
            // versionSqlsDict: key:版本号  object:NSArray<String>  只有一对值
            if ([[versionSqlsDict allKeys] count] > 0) {
                NSString *version = [[versionSqlsDict allKeys] objectAtIndex:0];
                if (version != nil && [version compare:preVersion] == NSOrderedDescending) {
                    NSArray *sqls = versionSqlsDict[version];
                    [sqls enumerateObjectsUsingBlock:^(id _Nonnull sql, NSUInteger idx, BOOL *_Nonnull stop2) {
                        if ([sql isKindOfClass:[NSString class]]) {
                            success = [self runCommands:@[sql]];
                            if (!success) {
                                // 跳出外层循环
                                *stop1 = YES;
                            }
                        } else if ([sql isKindOfClass:[NSArray class]]) {
                            success = [self runCommands:sql];
                            if (!success) {
                                *stop1 = YES;
                            }
                        } else {
                            *stop1 = YES;
                        }
                    }];
                }
            }
        }
    }];

    return success;
}

/**
 * 在事务中一次性运行多条sql数据
 */
- (BOOL)runCommands:(NSArray *)commandStrs {
    __block BOOL success = NO;

    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        for (NSString *sql in commandStrs) {
            success = [db executeUpdate:sql];
            if ([db hadError]) {
                success = NO;
                *rollback = YES;
                NSAssert(0, @"ERROR:%s运行sql语句%@发生错误:%@", __PRETTY_FUNCTION__, sql, [db lastErrorMessage]);
                break;
            }
        }
    }];

    return success;
}

#pragma mark - paths
/**
 * db路径(存在Documents下防止被清理掉）
 */
- (NSString *)DBPath {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [cachePath stringByAppendingPathComponent:@"my.db"];

    NSLog(@"----dbPath----%@", dbPath);

    return dbPath;
}

/**
 * 预置db路径
 */
- (NSString *)bundleDBPath {
    return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"my.db"];
}

/**
 * db升级的plist路径
 */
- (NSString *)updateDBPath {
    return [[NSBundle mainBundle] pathForResource:@"DBUpgradeSQL" ofType:@"plist"];
}

@end
