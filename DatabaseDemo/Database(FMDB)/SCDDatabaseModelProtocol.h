//
//  SCDDatabaseModelProtocol.h
//  DatabaseDemo
//
//  Created by swit on 2018/2/1.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "FMResultSet.h"

@protocol SCDDatabaseModelProtocol <NSObject>

+ (id<SCDDatabaseModelProtocol>)databaseModelWithFMResultSet:(FMResultSet *)rs;

@end
