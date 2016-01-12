//
//  main.m
//  GDRuntimeSimple
//
//  Created by 国栋 on 16/1/12.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDRuntime.h"

//测试用例
@protocol NullDelegate <NSObject>
@end

@interface Source : NSObject<NullDelegate>
{
    int num;
}
@property NSString *str;
-(void)method;
@end

@implementation Source
-(void)method{
    NSLog(@"成功");
}
@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //获取已有的信息
        GDClassInfomation *classInfo=[[GDClassInfomation alloc]initWithClass:[Source class]];
        [classInfo print];//全打印出来
        NSLog(@"==============================>>>");
        
        Class MyClass=[GDRuntime createNewClassWithName:@"MyClass" superClass:[NSObject class]];
        
        [GDRuntime addArray:classInfo.protocolList toClass:MyClass];//协议，实例变量，属性，方法，随便加什么，但是要注意放到数组里
        [GDRuntime addArray:classInfo.methodList toClass:MyClass];
        
        
        //新创建一个实例变量
        GDInstanceVariable *newIvar=[[GDInstanceVariable alloc]init];
        newIvar.name=@"kkk";
        newIvar.typeEncoding=@"i";
        [GDRuntime addArray:@[newIvar] toClass:MyClass];
        
        [[[GDClassInfomation alloc]initWithClass:MyClass]print];
        
        id newObj=[[MyClass alloc]init];
        
        
        NSLog(@"==============================>>>");
        
        [newObj method];
        
        
        [GDRuntime registerClass:MyClass];//注册不注册，随意～～～
        
    }
    return 0;
}
