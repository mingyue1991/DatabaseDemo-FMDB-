//
//  SCDStudent.m
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/31.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "SCDStudent.h"
#import "FMResultSet.h"

static NSString *const KSTUDENT_ID = @"student_id";
static NSString *const KSTUDENT_NAME = @"name";
static NSString *const KSTUDENT_GENDER = @"gender";
static NSString *const KSTUDENT_AGE = @"age";
static NSString *const KSTUDENT_CLASS_ID = @"class_id";

@implementation SCDStudent

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.studentId = [[dict objectForKey:KSTUDENT_ID] integerValue];
        self.name = [dict objectForKey:KSTUDENT_NAME];
        self.gender = [dict objectForKey:KSTUDENT_GENDER];
        self.age = [[dict objectForKey:KSTUDENT_AGE] integerValue];
        self.classId = [dict objectForKey:KSTUDENT_CLASS_ID];
    }

    return self;
}

+ (id<SCDDatabaseModelProtocol>)databaseModelWithFMResultSet:(FMResultSet *)rs {
    SCDStudent *student = [SCDStudent new];

    student.studentId = [rs intForColumn:KSTUDENT_ID];
    student.name = [rs stringForColumn:KSTUDENT_NAME];
    student.gender = [rs stringForColumn:KSTUDENT_GENDER];
    student.age = [rs intForColumn:KSTUDENT_AGE];
    student.classId = [rs stringForColumn:KSTUDENT_CLASS_ID];

    return student;
}

@end
