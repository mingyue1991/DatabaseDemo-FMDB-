//
//  ViewController.m
//  DatabaseDemo
//
//  Created by swit on 2018/1/31.
//  Copyright © 2018年 swit. All rights reserved.
//

#import "ViewController.h"
#import "SCDDatabaseManager+Student.h"
#import "SCDStudent.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    for (int i = 0; i < 30; i++) {
        SCDStudent *s = [[SCDStudent alloc] init];
        s.studentId = i;
        s.name = [self randomName];
        s.age = [self randomAge];
        s.classId = [self randomClass];
        s.gender = rand()%2?@"male":@"female";
        [[SCDDatabaseManager sharedManager] addStudent:s];
    }
//
//    Student *s = [[Student alloc] init];
//    s.studentId = 3;
//    [[DatabaseManager sharedManager] deleteStudent:s];

    NSArray *students = [[SCDDatabaseManager sharedManager]  getAllAdultStudents];

}

- (NSString *)randomName
{
    int NUMBER_OF_CHARS = 8;

    char data[NUMBER_OF_CHARS];

    for (int x=0; x<NUMBER_OF_CHARS;)
    {
        data[x++] = ('A' + (arc4random_uniform(26)));
    }

    return [[NSString alloc] initWithBytes:data length:NUMBER_OF_CHARS encoding:NSUTF8StringEncoding];
}

- (NSInteger)randomAge
{
    return random() % 30;
}

- (NSString *)randomClass
{
    return [NSString stringWithFormat:@"%@",@((random() % 20) + 1)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
