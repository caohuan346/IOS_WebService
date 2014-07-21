//
//  ServiceArgs.h
//  ZOSENDA
//
//  Created by hc on 14-7-17.
//  Copyright (c) 2014年 ZOSENDA GROUP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceArgs : NSObject
@property(nonatomic, copy) NSString *serviceURL;
@property(nonatomic, readonly) NSURL *webURL;
@property(nonatomic, copy) NSString *serviceNameSpace;

@property(nonatomic, copy) NSString *methodName;
@property(nonatomic, retain) NSArray *soapParams;

@property(nonatomic, readonly) NSString *defaultSoapMesage;
@property(nonatomic, copy) NSString *soapMessage;

@property(nonatomic, copy) NSData *sentData;
@property(nonatomic, copy) NSString *dataContentType;
@property(nonatomic, copy) NSString *dataName;

@property(nonatomic, readonly) NSMutableDictionary *headers;

-(id)initWithMethodName:(NSString *)methodName soapParamsArray:(NSArray *)paramsArray;
-(NSString*)stringSoapMessage:(NSArray*)params;

+(ServiceArgs*)serviceMethodName:(NSString*)methodName;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName soapMessage:(NSString*)soapMsg;

//setter
+(void)setNameSapce:(NSString*)space;
+(void)setWebServiceURL:(NSString*)url;

@end
