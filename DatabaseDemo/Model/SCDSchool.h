//
//  SCDSchool.h
//  DatabaseDemo
//
//  Created by swit on 2018/2/1.
//  Copyright © 2018年 swit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCDDatabaseModelProtocol.h"

@interface SCDSchool : NSObject<SCDDatabaseModelProtocol>

@property (nonatomic, assign) NSInteger schoolID;
@property (nonatomic, copy) NSString *name;

@end
