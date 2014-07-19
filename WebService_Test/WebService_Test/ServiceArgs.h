 

#import <Foundation/Foundation.h>

@interface ServiceArgs : NSObject
@property(nonatomic,copy) NSString *serviceURL;
@property(nonatomic,readonly) NSURL *webURL;
@property(nonatomic,copy) NSString *serviceNameSpace;
@property(nonatomic,copy) NSString *methodName;
@property(nonatomic,copy) NSString *soapMessage;
/////
@property(nonatomic,copy) NSData *sentData;
@property(nonatomic,copy) NSString *dataContentType;
@property(nonatomic,copy) NSString *dataName;
////
@property(nonatomic,readonly) NSMutableDictionary *headers;
//soapMessage处理
@property(nonatomic,readonly) NSString *defaultSoapMesage;
@property(nonatomic,retain) NSArray *soapParams;

-(id)initWithMethodName:(NSString *)methodName soapParamsArray:(NSArray *)paramsArray;
-(NSString*)stringSoapMessage:(NSArray*)params;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName;
+(ServiceArgs*)serviceMethodName:(NSString*)methodName soapMessage:(NSString*)soapMsg;

//webservice访问设置
+(void)setNameSapce:(NSString*)space;
+(void)setWebServiceURL:(NSString*)url;

@end
