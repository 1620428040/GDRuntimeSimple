//
//  GDRuntime.h
//  GDTableView
//
//  Created by 国栋 on 16/1/11.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@protocol ArrayOperateProtocol;//定义一些共有的操作
@class GDInstanceVariable;//类中的实例变量，对应Ivar
@class GDProperty;//类中的属性，对应objc_property_t
@class GDPropertyAttribute;//属性的属性，对应objc_property_attribute_t，是一些特别的编码
@class GDMethod;//类中的方法


@interface GDRuntime : NSObject

//运行时不支持对已经存在的类添加 实例变量，属性，方法，除非销毁重建
//对类的修改要在创建之后，注册之前进行，注册后的更改是无效的
//如果想要更改，只能销毁之前存在的类，重新创建  之前创建的这个类的实例也会被销毁
//未注册的类之间可以重名，但是不能与注册过的类重名
+(Class)getClassWithName:(NSString *)theName;
+(Class)createNewClassWithName:(NSString*)theName superClass:(Class)theSuperClass;
+(void)registerClass:(Class)theClass;
+(void)destroyClass:(Class)theClass;
+(void)printAllInfomationOfClass:(Class)theClass;


//抽取其他类的属性的时候要注意，有可能新的类中已经存在这个属性了
+(NSMutableArray *)getAllInstanceVariableInClass:(Class)theClass;
+(NSMutableArray *)getAllPropertyInClass:(Class)theClass;
+(NSMutableArray *)getAllMethodInClass:(Class)theClass;
+(NSMutableArray *)getAllProtocolInClass:(Class)theClass;

//对数组中的对象进行操作，不管数组中的对象是GDProperty，GDInstanceVariable，还是能支持的其他类都能操作，不支持的类会自动抛出
+(void)printArray:(NSArray*)theArray;
+(void)addArray:(NSArray*)theArray toClass:(Class)theClass;

@end


//数组操作协议
@protocol ArrayOperateProtocol <NSObject>

-(void)addToClass:(Class)theClass;
-(void)print;

@end


//类的信息－只读，不要试图用这个操作类
@interface GDClassInfomation : NSObject

@property Class relateClass;//关联的类，也就是说，读取的是这个类的信息

@property (readonly)NSString *name;
@property (readonly)BOOL hasRegister;
@property (readonly)Class superClass;
@property (readonly)int version;

@property (readonly)NSMutableArray *instanceVariableList;
@property (readonly)NSMutableArray *propertyList;
@property (readonly)NSMutableArray *methodList;
@property (readonly)NSMutableArray *protocolList;

-(instancetype)initWithClass:(Class)theClass;
-(void)print;

@end


//实例变量类
@interface GDInstanceVariable : NSObject<ArrayOperateProtocol>

@property NSString *name;
@property long offset;//偏移量
@property NSString *typeEncoding;//类型编码

-(instancetype)initWithIvar:(Ivar)theIvar;

@end


//类遵守的协议-协议应该不需要动态生成吧
@interface GDProtocol : NSObject<ArrayOperateProtocol>

@property NSString *name;
@property Protocol *relateProtocol;

-(instancetype)initWithProtocol:(Protocol*)theProtocol;

@end


//类中的属性 的类
@interface GDProperty : NSObject<ArrayOperateProtocol>

@property NSString *name;
//@property NSString *attributes;//attributeList代替
@property long attributeCount;
@property NSMutableArray *attributeList;//数组里面是GDPropertyAttribute对象

-(instancetype)initWith:(objc_property_t)the_objc_property_t;

@end


//属性的属性 的类
@interface GDPropertyAttribute : NSObject

@property NSString *name;
@property NSString *value;

-(instancetype)initWith:(objc_property_attribute_t)the_objc_property_attribute_t;
-(objc_property_attribute_t)transTo_objc_property_attribute_t;
-(void)print;

@end


//类中的方法的类
@interface GDMethod : NSObject<ArrayOperateProtocol>

@property SEL name;//选择器
@property NSString *selector;//选择器name的字符串形式，可以自动转化
@property IMP implementation;//指向实现方法的指针
@property NSString* typeEncoding;//类型编码

-(instancetype)initWith:(Method)theMethod;

-(NSString *)selector;
-(void)setSelector:(NSString *)selector;

@end


