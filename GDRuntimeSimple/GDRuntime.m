//
//  GDRuntime.m
//  GDTableView
//
//  Created by 国栋 on 16/1/11.
//  Copyright (c) 2016年 GD. All rights reserved.
//

#import "GDRuntime.h"

@implementation GDClassInfomation
@synthesize relateClass;

-(instancetype)initWithClass:(Class)theClass
{
    if (self=[super init]) {
        relateClass=theClass;
    }
    return self;
}
-(NSString *)name
{
    return [NSString stringWithCString:class_getName(relateClass) encoding:NSUTF8StringEncoding];
}
-(Class)superClass
{
    return class_getSuperclass(relateClass);
}
-(int)version
{
    return class_getVersion(relateClass);
}
-(NSMutableArray *)instanceVariableList
{
    return [GDRuntime getAllInstanceVariableInClass:relateClass];
}
-(NSMutableArray *)propertyList
{
    return [GDRuntime getAllPropertyInClass:relateClass];
}
-(NSMutableArray *)methodList
{
    return [GDRuntime getAllMethodInClass:relateClass];
}
-(NSMutableArray *)protocolList
{
    return [GDRuntime getAllProtocolInClass:relateClass];
}
//测试这个类有没有被注册
-(BOOL)hasRegister
{
    if(objc_getClass([self.name cStringUsingEncoding:NSUTF8StringEncoding])==nil){
        return NO;
    }
    else return YES;
}
-(void)print
{
    NSLog(@"类名：%@ 父类：%@ 版本号：%d 已注册：%d",self.name,self.superClass,self.version,self.hasRegister);
    [GDRuntime printArray:self.protocolList];
    [GDRuntime printArray:self.instanceVariableList];
    [GDRuntime printArray:self.propertyList];
    [GDRuntime printArray:self.methodList];
}

@end

@implementation GDProtocol

-(instancetype)initWithProtocol:(Protocol*)theProtocol
{
    if (self=[super init]) {
        self.name=[NSString stringWithCString:protocol_getName(theProtocol) encoding:NSUTF8StringEncoding];
        self.relateProtocol=theProtocol;
    }
    return self;
}
-(void)addToClass:(Class)theClass
{
    class_addProtocol(theClass, self.relateProtocol);
}
-(void)print
{
    NSLog(@"  遵守协议%@",self.name);
}


@end

@implementation GDInstanceVariable

-(instancetype)initWithIvar:(Ivar)theIvar
{
    if (self=[super init]) {
        self.name=[NSString stringWithCString:ivar_getName(theIvar) encoding:NSUTF8StringEncoding];
        self.offset=ivar_getOffset(theIvar);
        self.typeEncoding=[NSString stringWithCString:ivar_getTypeEncoding(theIvar) encoding:NSUTF8StringEncoding];
    }
    return self;
}
-(void)addToClass:(Class)theClass
{
    if (class_addIvar(theClass, [self.name cStringUsingEncoding:NSUTF8StringEncoding], 0, 0, [self.typeEncoding cStringUsingEncoding:NSUTF8StringEncoding])==NO) {
        NSLog(@"添加失败:");
        [self print];
    }
}
-(void)print
{
    NSLog(@"%@",[NSString stringWithFormat:@"  实例变量  名称：%@  偏移量：%ld  类型编码：%@",self.name,self.offset,self.typeEncoding]);
}

@end

@implementation GDProperty

-(instancetype)initWith:(objc_property_t)the_objc_property_t
{
    if (self=[super init]) {
        self.name=[NSString stringWithCString:property_getName(the_objc_property_t) encoding:NSUTF8StringEncoding];
        //self.attributes=[NSString stringWithCString:property_getAttributes(the_objc_property_t) encoding:NSUTF8StringEncoding];
        
        unsigned int count=0;
        self.attributeList=[NSMutableArray array];
        objc_property_attribute_t *list=property_copyAttributeList(the_objc_property_t, &count);
        self.attributeCount=count;
        for (int j=0; j<count; j++) {
            [self.attributeList addObject:[[GDPropertyAttribute alloc]initWith:list[j]]];
        }
    }
    return self;
}
-(void)addToClass:(Class)theClass
{
    objc_property_attribute_t list[self.attributeCount];
    for (int i=0; i<self.attributeCount; i++) {
        list[i]=[self.attributeList[i] transTo_objc_property_attribute_t];
    }
    if (class_addProperty(theClass, [self.name cStringUsingEncoding:NSUTF8StringEncoding], list, (unsigned)self.attributeCount)==NO) {
        NSLog(@"添加失败，可能是该属性已经存在了（由于继承关系，父类的属性也是无法添加的）:");
        [self print];
    }
}
-(void)print
{
    NSLog(@"%@",[NSString stringWithFormat:@"  实例属性  名称：%@ 属性数量：%ld 属性列表：",self.name/*,self.attributes*/,self.attributeCount]);
    for (GDPropertyAttribute *current in self.attributeList) {
        [current print];
    }
}

@end

@implementation GDPropertyAttribute

-(instancetype)initWith:(objc_property_attribute_t)the_objc_property_attribute_t
{
    if (self=[super init]) {
        self.name=[NSString stringWithCString:the_objc_property_attribute_t.name encoding:NSUTF8StringEncoding];
        self.value=[NSString stringWithCString:the_objc_property_attribute_t.value encoding:NSUTF8StringEncoding];
    }
    return self;
}
-(objc_property_attribute_t)transTo_objc_property_attribute_t
{
    objc_property_attribute_t new;
    new.name=[self.name cStringUsingEncoding:NSUTF8StringEncoding];
    new.value=[self.value cStringUsingEncoding:NSUTF8StringEncoding];
    return new;
}
-(void)print
{
    NSLog(@"%@",[NSString stringWithFormat:@"    属性名：%@  值：%@",self.name,self.value]);
}

@end

@implementation GDMethod

-(instancetype)initWith:(Method)theMethod
{
    if (self=[super init]) {
        self.name=method_getName(theMethod);
        self.implementation=method_getImplementation(theMethod);
        self.typeEncoding=[NSString stringWithCString:method_getTypeEncoding(theMethod) encoding:NSUTF8StringEncoding];
    }
    return self;
}
-(NSString *)selector
{
    return NSStringFromSelector(self.name);
}
-(void)setSelector:(NSString *)selector
{
    self.name=@selector(selector);
}
-(void)addToClass:(Class)theClass
{
    class_addMethod(theClass, self.name, self.implementation, [self.typeEncoding cStringUsingEncoding:NSUTF8StringEncoding]);
}
-(void)print
{
    NSLog(@"%@",[NSString stringWithFormat:@"  方法选择器：%@  类型编码：%@ 实现方法位置：%p",self.selector,self.typeEncoding,self.implementation]);
}

@end


@implementation GDRuntime

+(Class)getClassWithName:(NSString *)theName
{
    return objc_getClass([theName cStringUsingEncoding:NSUTF8StringEncoding]);
}
+(Class)createNewClassWithName:(NSString *)theName superClass:(Class)theSuperClass
{
    const char *name=[theName cStringUsingEncoding:NSUTF8StringEncoding];
    Class new=objc_allocateClassPair(theSuperClass, name, 0);
    return new;
}
+(void)registerClass:(Class)theClass
{
    objc_registerClassPair(theClass);
}
+(void)destroyClass:(Class)theClass
{
    objc_disposeClassPair(theClass);
}
+(void)printAllInfomationOfClass:(Class)theClass
{
    [self printArray:[self getAllInstanceVariableInClass:theClass]];
    [self printArray:[self getAllPropertyInClass:theClass]];
    [self printArray:[self getAllMethodInClass:theClass]];
}


+(NSMutableArray *)getAllInstanceVariableInClass:(Class)theClass
{
    unsigned int num=0;
    Ivar *ivarList=class_copyIvarList(theClass, &num);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<num; i++) {
        [array addObject:[[GDInstanceVariable alloc]initWithIvar:ivarList[i]]];
    }
    return array;
}
+(NSMutableArray *)getAllPropertyInClass:(Class)theClass
{
    unsigned int num=0;
    objc_property_t *propertyList=class_copyPropertyList(theClass, &num);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<num; i++) {
        [array addObject:[[GDProperty alloc]initWith:propertyList[i]]];
    }
    return array;
}
+(NSMutableArray *)getAllMethodInClass:(Class)theClass
{
    unsigned int num=0;
    Method *methodList=class_copyMethodList(theClass, &num);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<num; i++) {
        [array addObject:[[GDMethod alloc]initWith:methodList[i]]];
    }
    return array;
}
+(NSMutableArray *)getAllProtocolInClass:(Class)theClass
{
    unsigned int num=0;
    Protocol * __unsafe_unretained * protocolList=class_copyProtocolList(theClass, &num);
    NSMutableArray *array=[NSMutableArray array];
    for (int i=0; i<num; i++) {
        [array addObject:[[GDProtocol alloc]initWithProtocol:protocolList[i]]];
    }
    return array;
}


+(void)printArray:(NSArray *)theArray
{
    for (id current in theArray) {
        if ([current respondsToSelector:@selector(print)]) {
            [current print];
        }
        else NSLog(@"不支持的类%@",current);
    }
}
+(void)addArray:(NSArray *)theArray toClass:(Class)theClass
{
    for (id current in theArray) {
        if ([current respondsToSelector:@selector(addToClass:)]) {
            [current addToClass:theClass];
        }
        else NSLog(@"不支持的类%@",current);
    }
}
@end
