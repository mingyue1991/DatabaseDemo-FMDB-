//
//  SCDStudent.h
//  DatabaseDemo_FMDB
//
//  Created by swit on 2018/1/31.
//  Copyright © 2018年 swit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDDatabaseModelProtocol.h"

@interface SCDStudent : NSObject<SCDDatabaseModelProtocol>

@property (nonatomic, assign) NSInteger studentId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *gender;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, copy) NSString *classId;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
