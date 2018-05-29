//
//  SCDDatabaseManager+Student.h
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/31.
//  Copyright © 2018年 swit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDDatabaseManager.h"
@class SCDStudent;
@interface SCDDatabaseManager(Student)

- (BOOL)addStudent:(SCDStudent *)student;
- (BOOL)deleteStudent:(SCDStudent *)student;
- (BOOL)updateStudent:(SCDStudent *)student;
- (NSArray *)getAllStudents;
- (NSArray *)getAllAdultStudents;

@end
