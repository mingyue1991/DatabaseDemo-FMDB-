//
//  SCDSchool.m
//  DatabaseDemo
//
//  Created by swit on 2018/2/1.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "SCDSchool.h"


static NSString *const KSCHOOL_ID = @"school_id";
static NSString *const KSCHOOL_NAME = @"name";

@implementation SCDSchool

+ (id<SCDDatabaseModelProtocol>)databaseModelWithFMResultSet:(FMResultSet *)rs; {
    SCDSchool *school = [SCDSchool new];

    school.schoolID = [rs intForColumn:KSCHOOL_ID];
    school.name = [rs stringForColumn:KSCHOOL_NAME];

    return school;
}

@end
