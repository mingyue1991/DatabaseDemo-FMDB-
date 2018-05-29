//
//  SCDDatabaseManager+Student.m
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/31.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "SCDDatabaseManager+Student.h"
#import "SCDStudent.h"

@implementation SCDDatabaseManager (Student)
- (BOOL)addStudent:(SCDStudent *)student {
    BOOL __block success = NO;

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        success = [db executeUpdate:@"insert into student(student_id,name,gender,class_id,age) values (?,?,?,?,?)", @(student.studentId), student.name, student.gender, student.classId, @(student.age)];
        if ([db hadError]) {
            NSLog(@"error detail: %@", [db lastErrorMessage]);
        }
    }];

    return success;
}

- (BOOL)deleteStudent:(SCDStudent *)student {
    BOOL __block success = NO;

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        success = [self deleteStudent:student dataBase:db];
    }];

    return success;
}

/*
 * Extend，如果数据库稍复杂点的，可以在此类下面再添加operation操作层传入db和操作数据，这样方便重用代码
 例如：批量删除 可以在一个事务中完成，那么在在inTransaction中迭代为宜，复用单个删除的代码
 */

- (BOOL)deleteStudents:(NSArray *)students {
    BOOL __block success = NO;

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        for (SCDStudent *s in students) {
            success = [self deleteStudent:s];
            if (!success) {
                *rollback = YES;
                break;
            }
        }
    }];

    return success;
}

- (BOOL)deleteStudent:(SCDStudent *)student dataBase:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"delete from student where student_id = ?", @(student.studentId)];

    if ([db hadError]) {
        NSLog(@"error detail: %@", [db lastErrorMessage]);
    }

    return success;
}

- (BOOL)updateStudent:(SCDStudent *)student {
    BOOL __block success = NO;

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        success = [db executeUpdate:@"update student set name=?,gender=?,class_id=?,age=? where student_id=?", student.name, student.gender, student.classId, @(student.age), @(student.studentId)];
        if ([db hadError]) {
            NSLog(@"error detail: %@", [db lastErrorMessage]);
        }
    }];

    return success;
}

- (NSArray *)getAllStudents {
    NSMutableArray *students = [[NSMutableArray alloc] init];

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        FMResultSet *rs = [db executeQuery:@"select * from student"];
        while ([rs next]) {
            SCDStudent *student = (SCDStudent *)[SCDStudent databaseModelWithFMResultSet:rs];
            [students addObject:student];
        }
    }];

    return students;
}

- (NSArray *)getAllAdultStudents {
    NSMutableArray *students = [[NSMutableArray alloc] init];

    [self.dbQueue inTransaction:^(FMDatabase *_Nonnull db, BOOL *_Nonnull rollback) {
        FMResultSet *rs = [db executeQuery:@"select * from student where age > ?", @(18)];
        while ([rs next]) {
            SCDStudent *student = (SCDStudent *)[SCDStudent databaseModelWithFMResultSet:rs];
            [students addObject:student];
        }
    }];

    return students;
}

@end
