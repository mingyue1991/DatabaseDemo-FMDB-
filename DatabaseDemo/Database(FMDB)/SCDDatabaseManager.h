//
//  SCDDatabaseManager.h
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/30.
//  Copyright © 2018年 swit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface SCDDatabaseManager : NSObject

+ (SCDDatabaseManager *)sharedManager;

@property (nonatomic, strong, readonly) FMDatabaseQueue *dbQueue;

@end
