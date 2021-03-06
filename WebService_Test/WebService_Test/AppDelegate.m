//
//  AppDelegate.m
//  WebService_Test
//
//  Created by hc on 14-7-18.
//  Copyright (c) 2014年 ZOSENDA GROUP. All rights reserved.
//

#import "AppDelegate.h"
#import "ServiceHandler.h"
//#import "ServiceArgs.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableArray *params=[NSMutableArray array];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"13467803712",@"mobileCode", nil]];
    [params addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"userID", nil]];

    /**
     *  <?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
     <soap:Body>
     <getMobileCodeInfoResponse xmlns="http://WebXml.com.cn/">
     <getMobileCodeInfoResult>
     13467803712：湖南 郴州 湖南移动大众卡
     </getMobileCodeInfoResult>
     </getMobileCodeInfoResponse>
     </soap:Body>
     </soap:Envelope>
     */
    
    [[ServiceHandler sharedInstance] asynRequest:@"getMobileCodeInfo" withParamsArray:params success:^(ServiceResult *result) {
        NSLog(@"%@",result.xmlParse);

        NSArray *array=[result.xmlParse soapXmlSelectNodes:@"//xmlns:getMobileCodeInfoResult"];
        NSString *numberInfo = array[0][@"text"];
        NSLog(@"%@",numberInfo);
        
    } failed:^(NSError *error, NSDictionary *userInfo) {
        
    }];

    /*
    [[ServiceHandler sharedInstance] asynService:args success:^(ServiceResult *result){
        NSLog(@"%@",result);
        
       
        NSArray *arr=[result.xmlParse soapXmlSelectNodes:@"//xmlns:GetPlanListResult"];
        NSDictionary *dic = [arr[0][@"text"] objectFromJSONString];
        
        if ([dic[@"Result"]  intValue] == 1) {
            
        }else {
            
        }
     
    } failed:^(NSError *error, NSDictionary *userInfo){
        NSLog(@"111111");
    }];
    */
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
