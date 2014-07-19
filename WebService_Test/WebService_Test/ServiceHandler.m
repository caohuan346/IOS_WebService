

#import "ServiceHandler.h"

@interface ServiceHandler()

//reset queue
-(void)resetQueue;
-(NSString*)soapAction:(NSString*)namespace methodName:(NSString*)methodName;
-(ASIHTTPRequest*)requestWithServerArgs:(ServiceArgs*)args;

@end

@implementation ServiceHandler
@synthesize delegate,httpRequest;
@synthesize networkQueue;

//单例模式
+ (ServiceHandler *)sharedInstance{
    static dispatch_once_t  onceToken;
    static ServiceHandler * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[ServiceHandler alloc] init];
    });
    return sSharedInstance;
}

#pragma mark - init
-(id)initWithDelegate:(id<ServiceHandlerDelegate>)theDelegate
{
	if (self=[super init]) {
		self.delegate=theDelegate;
        if (self.networkQueue) {
            self.networkQueue=[[ASINetworkQueue alloc] init];
        }
	}
	return self;
}

#pragma mark - public request
-(ASIHTTPRequest*)commonSharedRequest:(ServiceArgs*)args{
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:args.webURL];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [args.soapMessage length]];
	
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
	[request addRequestHeader:@"Host" value:[args.webURL host]];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
	[request addRequestHeader:@"Content-Length" value:msgLength];
    [request addRequestHeader:@"SOAPAction" value:[self soapAction:args.serviceNameSpace methodName:args.methodName]];
    [request setRequestMethod:@"POST"];
    //设置用户信息
    //[request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:args.methodName,@"name", nil]];
	//传soap信息
    [request appendPostData:[args.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30.0];//表示30秒请求超时
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    return request;
}

+(ASIHTTPRequest*)commonSharedRequest:(ServiceArgs*)args{
    ServiceHandler *helper=[[[ServiceHandler alloc] init] autorelease];
    return [helper commonSharedRequest:args];
}
#pragma mark - sync request
-(ServiceResult*)syncService:(ServiceArgs*)args{
    return [self syncService:args error:nil];
}

-(ServiceResult*)syncService:(ServiceArgs*)args error:(NSError**)error
{
    ASIHTTPRequest *request=[self requestWithServerArgs:args];
    
    //sync
    [request startSynchronous];
    if (error) {
        *error=[request error];
    }
    //handle result
    return [ServiceResult requestResult:request];
}

-(ServiceResult*)syncServiceMethodName:(NSString*)methodName{
    return [self syncServiceMethodName:methodName error:nil];
}

-(ServiceResult*)syncServiceMethodName:(NSString*)methodName error:(NSError**)error{
    ServiceArgs *args=[ServiceArgs serviceMethodName:methodName];
    return  [self syncService:args error:error];
}

+(ServiceResult*)syncService:(ServiceArgs*)args
{
    return [ServiceHandler syncService:args error:nil];
}

+(ServiceResult*)syncService:(ServiceArgs*)args error:(NSError**)error
{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    return [helper syncService:args error:error];
}

+(ServiceResult*)syncMethodName:(NSString*)methodName{
    return [self syncMethodName:methodName error:nil];
}

+(ServiceResult*)syncMethodName:(NSString*)methodName error:(NSError**)error{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    return [helper syncServiceMethodName:methodName error:error];
}

#pragma mark - asyn request
-(ASIHTTPRequest*)requestWithServerArgs:(ServiceArgs*)args{
    NSString *msgLength = [NSString stringWithFormat:@"%d", [args.soapMessage length]];
    ASIHTTPRequest *request=[ASIHTTPRequest requestWithURL:args.webURL];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
    [request addRequestHeader:@"Host" value:[args.webURL host]];
    [request addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
	[request addRequestHeader:@"Content-Length" value:msgLength];
    [request addRequestHeader:@"SOAPAction" value:[self soapAction:args.serviceNameSpace methodName:args.methodName]];
    [request setRequestMethod:@"POST"];
    
    //设置用户信息
    //[self.httpRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:args.methodName,@"name", nil]];
    
	//传soap信息
    [request appendPostData:[args.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValidatesSecureCertificate:NO];
    [request setTimeOutSeconds:30.0];//表示30秒请求超时
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    return request;
}
-(void)asynService:(ServiceArgs*)args{
    [self.httpRequest clearDelegatesAndCancel];
    [self setHttpRequest:[ASIHTTPRequest requestWithURL:args.webURL]];
    
    NSString *msgLength = [NSString stringWithFormat:@"%d", [args.soapMessage length]];
	
    //或者[self.httpRequest setRequestHeaders:args.headers];
    
    //以下对请求信息添加属性前四句是必有的，第五句是soap信息。
	[self.httpRequest addRequestHeader:@"Host" value:[args.webURL host]];
    [self.httpRequest addRequestHeader:@"Content-Type" value:@"text/xml; charset=utf-8"];
	[self.httpRequest addRequestHeader:@"Content-Length" value:msgLength];
    [self.httpRequest addRequestHeader:@"SOAPAction" value:[self soapAction:args.serviceNameSpace methodName:args.methodName]];
    [self.httpRequest setRequestMethod:@"POST"];
    
    //设置用户信息
    //[self.httpRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:args.methodName,@"name", nil]];
    
	//传soap信息
    [self.httpRequest appendPostData:[args.soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    [self.httpRequest setValidatesSecureCertificate:NO];
    [self.httpRequest setTimeOutSeconds:30.0];//表示30秒请求超时
    [self.httpRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(progressRequest:)]) {
        [self.delegate progressRequest:self.httpRequest];
    }
    if (_progressBlock) {
        _progressBlock(self.httpRequest);
    }
    
    [self.httpRequest setDelegate:self];
    
    //asyn request
	[self.httpRequest startAsynchronous];
}

-(void)asynService:(ServiceArgs*)args delegate:(id<ServiceHandlerDelegate>)theDelegate{
    self.delegate=theDelegate;
    [self asynService:args];
}

-(ASIHTTPRequest*)asynRequest:(NSString *)methodName withParamsArray:(NSArray *)paramsArray success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{  
    ServiceArgs *args = [[[ServiceArgs alloc] initWithMethodName:methodName soapParams:paramsArray] autorelease];
   return  [self asynService:args progress:nil success:finished failed:failed];
}

-(ASIHTTPRequest*)asynService:(ServiceArgs*)args success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    return  [self asynService:args progress:nil success:finished failed:failed];
}

-(ASIHTTPRequest*)asynService:(ServiceArgs*)args progress:(void(^)(ASIHTTPRequest*))progress success:(void(^)(ServiceResult*))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    
    //__block ASIHTTPRequest *request=[self requestWithServerArgs:args];
    
    ASIHTTPRequest *request=[self requestWithServerArgs:args];
    if (progress) {
        progress(request);
    }
    [request setCompletionBlock:^{
        ServiceResult *serviceresult=[ServiceResult requestResult:request];
        if (finished) {
            finished(serviceresult);
        }
    }];
    [request setFailedBlock:^{
        if (failed) {
            //  取消时不显示
            if ([[request.error description]  rangeOfString:@"cancelled"].location == NSNotFound  ) {
                
                failed(request.error,request.userInfo);
            }
        }
    }];
    [request startAsynchronous];
    
    return request;
}

-(void)asynServiceMethodName:(NSString*)methodName delegate:(id<ServiceHandlerDelegate>)theDelegate{
    ServiceArgs *args=[ServiceArgs serviceMethodName:methodName];
    [self asynService:args delegate:theDelegate];
}

-(ASIHTTPRequest*)asynServiceMethodName:(NSString*)methodName success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    return [self asynServiceMethodName:methodName progress:nil success:finished failed:failed];
}

-(ASIHTTPRequest*)asynServiceMethodName:(NSString*)methodName progress:(void(^)(ASIHTTPRequest*))progress success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    ServiceArgs *args=[ServiceArgs serviceMethodName:methodName];
    return [self asynService:args progress:progress success:finished failed:failed];
}

+(void)asynService:(ServiceArgs*)args delegate:(id<ServiceHandlerDelegate>)theDelegate
{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    helper.delegate=theDelegate;
    [helper asynService:args];
}

+(void)asynService:(ServiceArgs*)args success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    [ServiceHandler asynService:args progress:nil success:finished failed:failed];
}

+(void)asynService:(ServiceArgs*)args progress:(void(^)(ASIHTTPRequest*))progress success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    [helper asynService:args progress:progress success:finished failed:failed];
}

+(void)asynMethodName:(NSString*)methodName delegate:(id<ServiceHandlerDelegate>)theDelegate{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    [helper asynServiceMethodName:methodName delegate:theDelegate];
}

+(void)asynMethodName:(NSString*)methodName success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    [self asynMethodName:methodName progress:nil success:finished failed:failed];
}

+(void)asynMethodName:(NSString*)methodName progress:(void(^)(ASIHTTPRequest*))progress success:(void(^)(ServiceResult* result))finished failed:(void(^)(NSError *error,NSDictionary *userInfo))failed{
    ServiceHandler *helper=[ServiceHandler sharedInstance];
    ServiceArgs *args=[ServiceArgs serviceMethodName:methodName];
    [helper asynService:args progress:progress success:finished failed:failed];
}

#pragma mark - ASIHTTPRequest delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    ServiceResult *result=[ServiceResult requestResult:request];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(finishSoapRequest:)]) {
        [self.delegate finishSoapRequest:result];
    }

	if(_finishBlock){
        _finishBlock(result);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
    if(self.delegate&&[self.delegate respondsToSelector:@selector(failedSoapRequest:userInfo:)]){
        [self.delegate failedSoapRequest:error userInfo:[request userInfo]];
    }
    
    if (_failedBlock) {
        _failedBlock(error,[request userInfo]);
    }
}


#pragma mark -
#pragma mark queue request
//开始排列
-(BOOL)cancelForMenthod:(NSString*)methodName{
    NSArray *array=[[ASIHTTPRequest  sharedQueue] operations];
    for (ASIHTTPRequest *request in array) {
        if ([request.requestHeaders[@"SOAPAction"] rangeOfString:methodName].location != NSNotFound) {
            [request cancel];
            return YES;
        }
    }
    return NO;
}

-(void)resetQueue{
    if (!self.networkQueue) {
        self.networkQueue = [[ASINetworkQueue alloc] init];
    }
    [self.networkQueue reset];
    //表示队列操作完成
    [self.networkQueue setQueueDidFinishSelector:@selector(queueFetchComplete:)];
    [self.networkQueue setRequestDidFinishSelector:@selector(requestFetchComplete:)];
    [self.networkQueue setRequestDidFailSelector:@selector(requestFetchFailed:)];
    [self.networkQueue setDelegate:self];
}

-(void)startQueue{
    [self resetQueue];
    for (ASIHTTPRequest *item in _requestList) {
        [self.networkQueue addOperation:item];
    }
    [self.networkQueue go];
}

//添加队列
-(void)addQueue:(ASIHTTPRequest*)request{
    if (!_requestList) {
        _requestList=[[NSMutableArray alloc] init];
        if (!_queueResults) {
            _queueResults=[[NSMutableArray alloc] init];
        }else{
            [_queueResults removeAllObjects];
        }
    }
    [_requestList addObject:request];
}

-(void)addRangeQueue:(NSArray*)requests{
    if (!_requestList) {
        _requestList=[[NSMutableArray alloc] init];
        if (!_queueResults) {
            _queueResults=[[NSMutableArray alloc] init];
        }else{
            [_queueResults removeAllObjects];
        }
    }
    [_requestList removeAllObjects];
    _requestList=[NSMutableArray arrayWithArray:requests];
}

//队列请求处理
-(void)queueFetchComplete:(ASIHTTPRequest*)request{
    if(self.delegate&&[self.delegate respondsToSelector:@selector(finishQueueComplete:)]){
        [self.delegate finishQueueComplete:_queueResults];
    }
    if (_finishQueueBlock) {
        _finishQueueBlock(_queueResults);
    }
    if (_requestList) {
        [_requestList removeAllObjects];
    }
    if (_queueResults) {
        [_queueResults removeAllObjects];
    }
}

-(void)requestFetchComplete:(ASIHTTPRequest*)request{
    
	ServiceResult *result=[ServiceResult requestResult:request];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(finishSoapRequest:)]) {
        [self.delegate finishSoapRequest:result];
    }
    if (_finishBlock) {
        _finishBlock(result);
    }
    if (_queueResults) {
        [_queueResults addObject:result];
    }
    
}

-(void)requestFetchFailed:(ASIHTTPRequest*)request{
    
    if(self.delegate&&[self.delegate respondsToSelector:@selector(failedSoapRequest:userInfo:)]){
        [self.delegate failedSoapRequest:[request error] userInfo:[request userInfo]];
    }
    if (_failedBlock) {
        _failedBlock([request error],[request userInfo]);
    }
}

-(void)startQueue:(id<ServiceHandlerDelegate>)theDelegate{
    self.delegate=theDelegate;
    [self startQueue:nil failed:nil complete:nil];
}

-(void)startQueue:(finishBlockRequest)finish failed:(failedBlockRequest)failed complete:(finishBlockQueueComplete)finishQueue{
    
    Block_release(_failedBlock);
    Block_release(_finishBlock);
    Block_release(_finishQueueBlock);
    
    _finishBlock=Block_copy(finish);
    _failedBlock=Block_copy(failed);
    _finishQueueBlock=Block_copy(finishQueue);
    
    [self startQueue];
}

#pragma mark private
-(NSString*)soapAction:(NSString*)namespace methodName:(NSString*)methodName{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"/$" options:0 error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
    //NSArray *array=[regex matchesInString:namespace options:0 range:NSMakeRange(0, [namespace length])];
    
    if(numberOfMatches>0){
        return [NSString stringWithFormat:@"%@%@",namespace,methodName];
    }
#warning ---- soapAction generate
    //return [NSString stringWithFormat:@"%@/ZSDServices/%@",[namespace stringByReplacingOccurrencesOfString:@"https:" withString:@"http:"],methodName];
    return [NSString stringWithFormat:@"%@/%@",[namespace stringByReplacingOccurrencesOfString:@"https:" withString:@"http:"],methodName];
}

-(void)dealloc{
    Block_release(_failedBlock);
    Block_release(_finishBlock);
    Block_release(_finishQueueBlock);
    Block_release(_progressBlock);
    [httpRequest clearDelegatesAndCancel];
    [httpRequest release];
    [networkQueue reset];
    [networkQueue release];
    if (_requestList) {
        [_requestList release];
    }
    if (_queueResults) {
        [_queueResults release];
    }
	[super dealloc];
}

@end
