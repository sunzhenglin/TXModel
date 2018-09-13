//
//  TXModel.m
//  TXModel
//
//  Created by xtz_pioneer on 2018/5/29.
//  Copyright © 2018年 zhangxiong. All rights reserved.
//

#import "TXModel.h"

@implementation TXModel

/**
 *  使用字典初始化 (对象方法)
 *  @param dictionary 字典 (必填)
 */
- (instancetype)initWithDictionary:(NSDictionary*)dictionary{
    if (self = [super init]) {
        unsigned int outCount;
        objc_property_t * arrPropertys = class_copyPropertyList([self class],&outCount);
        for (NSInteger index = 0; index < outCount; index ++) {
            objc_property_t property = arrPropertys[index];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            id propertyValue =dictionary[propertyName];
            if (!propertyValue){
            }else if ([propertyValue isEqual:[NSNull class]]){
            }else{
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        free(arrPropertys);
    }
    return self;
}

/**
 *  使用字典初始化 (类方法)
 *  @param dictionary 字典 (必填)
 */
+ (instancetype)modelWithDictionary:(NSDictionary*)dictionary{
    return [[self alloc]initWithDictionary:dictionary];
}

/**
 *  使用Json初始化 (对象方法)
 *  @param jsonString Json字符串 (必填)
 */
- (instancetype)initWithJsonString:(NSString*)jsonString{
    if (self = [super init]) {
        NSDictionary * dict=[TXModel dictionaryWithJsonString:jsonString];
        unsigned int outCount;
        objc_property_t * arrPropertys = class_copyPropertyList([self class],&outCount);
        for (NSInteger index=0;index<outCount;index++) {
            objc_property_t property=arrPropertys[index];
            NSString *propertyName=[NSString stringWithUTF8String:property_getName(property)];
            id propertyValue=dict[propertyName];
            if (!propertyValue){
            }else if ([propertyValue isEqual:[NSNull class]]){
            }else{
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        free(arrPropertys);
    }
    return self;
}

/**
 *  使用Json初始化 (类方法)
 *  @param jsonString Json字符串 (必填)
 */
+ (instancetype)modelWithJsonString:(NSString*)jsonString{
    return [[TXModel alloc]initWithJsonString:jsonString];
}

/**
 *  获取对象的值
 */
+ (NSDictionary*)objectValue:(id)obj{
    if (!obj) return nil;
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t * arrPropertys = class_copyPropertyList([obj class],&outCount);
    for(NSInteger index=0;index<outCount;index++) {
        objc_property_t property = arrPropertys[index];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        id value=[obj valueForKey:propertyName];
        if(!value) {
            value=[NSNull null];
        }else{
            value=[self objectInternal:value];
        }
        [dict setObject:value forKey:propertyName];
    }
    return dict;
}

/**
 *  获取对象内部
 */
+ (id)objectInternal:(id)obj{
    if (!obj) return nil;
    if([obj isKindOfClass:[NSString class]]
       ||
       [obj isKindOfClass:[NSNumber class]]
       ||
       [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for(NSInteger index=0;index<arr.count;index++) {
            [arr setObject:[self objectInternal:[objarr objectAtIndex:index]] atIndexedSubscript:index];
        }
        return arr;
    }
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdict = obj;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[objdict count]];
        for(NSString *key in objdict.allKeys) {
            [dict setObject:[self objectInternal:[objdict objectForKey:key]] forKey:key];
        }
        return dict;
    }
    return [self objectValue:obj];
}

/**
 *  字典转化为数组
 *  @param dictionary 字典 (必填)
 */
+ (NSArray*)dictionaryTransitionsAarrayWithDictionary:(NSDictionary*)dictionary{
    if (!dictionary) return nil;
    NSMutableArray * muArray=[NSMutableArray array];
    for (NSString * key in dictionary.allKeys) {
        NSObject * obj = dictionary[key];
        [muArray addObject:obj];
    }
    return muArray;
}

/**
 *  当前对象的值
 */
- (NSDictionary*)valueForKey{
    return [TXModel objectValue:self];
}

/**
 *  当前对象的值的集合
 */
- (NSArray*)valueForArray{
    return [TXModel dictionaryTransitionsAarrayWithDictionary:self.valueForKey];
}

/**
 *  Json转字典
 *  @param jsonString Json字符串 (必填)
 */
+ (NSDictionary*)dictionaryWithJsonString:(NSString *)jsonString{
    if (!jsonString) return nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) return nil;
    return dic;
}

/**
 *  字典转Json
 *  @param dictionary 字典 (必填)
 */
+ (NSString*)jsonStringWithDictionary:(NSDictionary*)dictionary{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (jsonData) {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

/**
 *  当前对象的Json
 */
- (NSString*)valueForJsonString{
    return [TXModel jsonStringWithDictionary:self.valueForKey];
}

/**
 *  批量将数据转成该类模型集合
 *  @param dictionarys 字典集合 (必填)
 */
+ (NSArray*)arrayOfModelsFromDictionarys:(NSArray<NSDictionary*>*)dictionarys{
    if (!dictionarys){
        return nil;
    }else if ([dictionarys isEqual:[NSNull class]]){
        return nil;
    }else{
        NSMutableArray*list=[NSMutableArray arrayWithCapacity:[dictionarys count]];
        for (NSDictionary*dictionary in dictionarys) {
            [list addObject:[[self alloc]initWithDictionary:dictionary]];
        }
        return list;
    }
}

@end
