//
//  XmlParseHelperTester.m
//  WebService_Test
//
//  Created by hc on 14-7-20.
//  Copyright (c) 2014年 ZOSENDA GROUP. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ServiceHandler.h"

@interface XmlParseHelperTester : XCTestCase

@end

@implementation XmlParseHelperTester

- (XmlParseHelper *) xmlParse
{
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"13467803712",@"mobileCode", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"userID", nil]];
    
    __block XmlParseHelper *xmlParse;
    [[ServiceHandler sharedInstance] asynRequest:@"getMobileCodeInfo" withParamsArray:params success:^(ServiceResult *result) {
        xmlParse =  result.xmlParse;

    } failed:^(NSError *error, NSDictionary *userInfo) {
        xmlParse = nil;
    }];
    
    return xmlParse;
}

- (void)testExample
{
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"13467803712",@"mobileCode", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"userID", nil]];
    
    
    [[ServiceHandler sharedInstance] asynRequest:@"getMobileCodeInfo" withParamsArray:params success:^(ServiceResult *result) {
        NSLog(@"%@",result);
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
    }];
    
//    XmlParseHelper *xmlParse = [self xmlParse];
//    NSString *soapMsg = [xmlParse soapMessageResultXml:@"getMobileCodeInfo"];
//    NSLog(@"%@",soapMsg);
}

@end
