//
//  ServiceArgs.h
//  ZOSENDA
//
//  Created by hc on 14-7-17.
//  Copyright (c) 2014年 ZOSENDA GROUP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceArgs : NSObject

@property(nonatomic, readonly) NSURL *webURL;

@property(nonatomic, copy) NSString *serviceURL;

/**
 *  nameSpace
 */
@property(nonatomic, copy) NSString *serviceNameSpace;

/**
 *  请求方法名
 */
@property(nonatomic, copy) NSString *methodName;

/**
 *  参数数组
 */
@property(nonatomic, retain) NSArray *soapParams;

/**
 *  默认soap
 */
@property(nonatomic, readonly) NSString *defaultSoapMesage;

/**
 *  soap
 */
@property(nonatomic, copy) NSString *soapMessage;

/**
 *  header
 */
@property(nonatomic, readonly) NSMutableDictionary *headers;

//@property(nonatomic, copy) NSData *sentData;
//@property(nonatomic, copy) NSString *dataContentType;
//@property(nonatomic, copy) NSString *dataName;

-(id)initWithMethodName:(NSString *)methodName soapParamsArray:(NSArray *)paramsArray;

-(NSString*)stringSoapMessage:(NSArray*)params;

+(ServiceArgs*)serviceMethodName:(NSString*)methodName;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName soapMessage:(NSString*)soapMsg;

//setters
+(void)setNameSapce:(NSString*)space;
+(void)setWebServiceURL:(NSString*)url;

@end
