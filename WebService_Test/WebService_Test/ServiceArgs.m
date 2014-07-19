 
#import "ServiceArgs.h"

@interface ServiceArgs()
-(NSString*)paramsFormatString:(NSArray*)params;
@end

//
static NSString *defaultWebServiceUrl= //@"https://mobile.tuandai.com:8333/Tuan.svc";
//@"http://183.63.225.90:800/TuanDai.MobileSystem.WcfHost/Tuan.svc";
@"http://192.168.1.8/TuanDai.MobileSystem.WcfHost/Tuan.svc";
//@"https://mobile.tuandai.com:8333/Tuan.svc";
//@"https://121.13.64.21:8333/tuan.svc";
static NSString *defaultWebServiceNameSpace=@"http://mobile.tuandai.com";

@implementation ServiceArgs
@synthesize serviceURL,serviceNameSpace;
@synthesize methodName,soapMessage;
@synthesize webURL,headers,defaultSoapMesage;
@synthesize soapParams;


+(void)setWebServiceURL:(NSString*)url
{
    if (defaultWebServiceUrl!=url) {
        [defaultWebServiceUrl release];
        defaultWebServiceUrl=[url retain];
    }
}
+(void)setNameSapce:(NSString*)space
{
    if (defaultWebServiceNameSpace!=space) {
        [defaultWebServiceNameSpace release];
        defaultWebServiceNameSpace=[space retain];
    }
}

#pragma mark -
#pragma mark 属性重写
-(NSString*)defaultSoapMesage{
    NSString *soapBody=@"<?xml version=\"1.0\"?><soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:Tuan=\"http://tempuri.org/\" xmlns:tns1=\"http://mobile.tuandai.com\" xmlns:ns1=\"http://mobile.tuandai.com/Imports\" xmlns:tns2=\"http://schemas.microsoft.com/2003/10/Serialization/\" xsl:version=\"1.0\">\n"
    "<soap:Body>%@</soap:Body></soap:Envelope>";
    return soapBody;
}
-(NSURL*)webURL{
    return [NSURL URLWithString:[self serviceURL]];
}
-(NSString*)serviceURL{
    if (serviceURL) {
        return serviceURL;
    }
    return defaultWebServiceUrl;
}
-(NSString*)serviceNameSpace{
    if (serviceNameSpace) {
        return serviceNameSpace;
    }
    return defaultWebServiceNameSpace;
}
-(NSString*)soapMessage{
//    if (soapMessage) {
//        return soapMessage;
//    } 
    return [self stringSoapMessage:[self soapParams]];
}
-(NSMutableDictionary*)headers{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setValue:[[self webURL] host] forKey:@"Host"];
    [dic setValue:@"text/xml; charset=utf-8" forKey:@"Content-Type"];
    [dic setValue:[NSString stringWithFormat:@"%d",[[self soapMessage] length]] forKey:@"Content-Length"];
    [dic setValue:[NSString stringWithFormat:@"%@%@",[self serviceNameSpace],[self methodName]] forKey:@"SOAPAction"];
    return dic;
}
#pragma mark -
#pragma mark 私有方法
-(NSString*)paramsFormatString:(NSArray*)params{
    NSMutableString *xml=[NSMutableString stringWithFormat:@""];
    for (NSDictionary *item in params) {
        NSString *key=[[item allKeys] objectAtIndex:0];
        [xml appendFormat:@"<%@>",key];
        [xml appendString:[item objectForKey:key]];
        [xml appendFormat:@"</%@>",key];
    }
    return xml;
}


-(NSString*)paramsFormatJsonString:(NSArray*)params{
    NSMutableString *json=[NSMutableString stringWithFormat:@"{"];
    for (NSDictionary *item in params) {
        NSString *key=[[item allKeys] objectAtIndex:0];

        [json appendFormat:@"\"%@\":",key];
        //[json appendString:[item objectForKey:key]];
        [json appendFormat:@"\"%@\",",[item objectForKey:key]];
    }
    
    [json deleteCharactersInRange:NSMakeRange([json length] - 1 , 1)];
    
    [json  appendFormat:@"}"];
    
    if ([json  isEqualToString:@""])
        [json setString:@""];
    
    return json;
}
#pragma mark -
#pragma mark 公有方法
-(NSString*)stringSoapMessage:(NSArray*)params{
    if (params) {
        NSMutableString *soap=[NSMutableString stringWithFormat:@"<tns1:%@><tns1:jsonString>",[self methodName]];
        
        [soap appendString:[self paramsFormatJsonString:params]];
        [soap appendFormat:@"</tns1:jsonString></tns1:%@>",[self methodName]];
        
        return [NSString stringWithFormat:[self defaultSoapMesage],soap];
    }
    
    NSString *body=[NSString stringWithFormat:@"<%@ xmlns=\"%@\" />",[self methodName],[self serviceNameSpace]];
    
    return [NSString stringWithFormat:[self defaultSoapMesage],body];
}
+(ServiceArgs*)serviceMethodName:(NSString*)methodName{
    return [self serviceMethodName:methodName soapMessage:nil];
}
+(ServiceArgs*)serviceMethodName:(NSString*)name soapMessage:(NSString*)msg{
    ServiceArgs *args=[[[ServiceArgs alloc] init] autorelease];
    args.methodName=name;
    if (msg&&[msg length]>0) {
        args.soapMessage=msg;
    }else{
        args.soapMessage=[args stringSoapMessage:nil];
    }
    return args;
}
@end
