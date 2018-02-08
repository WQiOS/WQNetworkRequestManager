//
//  WQNetworkRequestManager.m
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/2/8.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import "WQNetworkRequestManager.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
#import "AFNetworking.h"

@implementation WQNetworkRequestManager

#pragma mark - shareManager
/**
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类的实例
 */
+ (instancetype)shareManager {
    static WQNetworkRequestManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

#pragma mark - 重写initWithBaseURL
/**
 *
 *
 *  @param url baseUrl
 *
 *  @return 通过重写夫类的initWithBaseURL方法,返回网络请求类的实例
 */

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        /**设置请求超时时间*/
        self.requestSerializer.timeoutInterval = 3;
        /**设置相应的缓存策略*/
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

        /**分别设置请求以及相应的序列化器*/
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;

        self.responseSerializer = response;

        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        /**设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        [self.requestSerializer setValue:@"token" forHTTPHeaderField:@"apikey"];

        /**设置接受的类型*/
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil]];

        /*!
         *** https 参数配置 *** 王强好帅！
         */
        self.securityPolicy = [self customSecurityPolicy];
    }
    return self;
}

#pragma mark - 支持https
- (AFSecurityPolicy *)customSecurityPolicy
{
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    [securityPolicy setAllowInvalidCertificates:YES];
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}

#pragma mark - 网络请求的类方法---get/post

/**
 *  网络请求的实例方法
 *
 *  @param type          get / post
 *  @param urlString     请求的地址
 *  @param paraments     请求的参数
 *  @param successBlock  请求成功的回调
 *  @param failureBlock  请求失败的回调
 *  @param progressBlock 进度
 */
+ (void)requestWithType:(HttpRequestType)type
          withUrlString:(NSString *)urlString
          withParaments:(id)paraments
       withSuccessBlock:(void(^)(NSDictionary * object))successBlock
       withFailureBlock:(void(^)(NSError *error))failureBlock
               progress:(void(^)(float progress))progressBlock{
    switch (type) {
        case HttpRequestTypeGet:
        {
            [[WQNetworkRequestManager shareManager] GET:urlString parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {
                if (progressBlock) {
                    progressBlock(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (successBlock) {
                    successBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
            break;
        }
        case HttpRequestTypePost:
        {
            [[WQNetworkRequestManager shareManager] POST:urlString parameters:paraments progress:^(NSProgress * _Nonnull uploadProgress) {
                if (progressBlock) {
                    progressBlock(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (successBlock) {
                    successBlock(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        }
    }
}

#pragma mark - 多图上传
/**
 *  上传图片
 *
 *  @param operations     上传图片预留参数---视具体情况而定 可移除
 *  @param imageArray     上传的图片数组
 *  @parm width           图片要被压缩到的宽度
 *  @param urlString      上传的url
 *  @param successBlock   上传成功的回调
 *  @param failureBlock   上传失败的回调
 *  @param progressBlock  上传进度
 */

+ (void)uploadImageWithOperations:(NSDictionary *)operations
                   withImageArray:(NSArray *)imageArray
                  withtargetWidth:(CGFloat )width
                    withUrlString:(NSString *)urlString
                 withSuccessBlock:(void(^)(NSDictionary * object))successBlock
                  withFailurBlock:(void(^)(NSError *error))failureBlock
               withUpLoadProgress:(void(^)(float progress))progressBlock{
    //1.创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSUInteger i = 0 ;
        /**出于性能考虑,将上传图片进行压缩*/
        for (UIImage * image in imageArray) {
            //image的分类方法
            NSData * imgData = UIImageJPEGRepresentation(image, .5);
            //拼接data
            [formData appendPartWithFileData:imgData name:[NSString stringWithFormat:@"picflie%ld",(long)i] fileName:@"image.png" mimeType:@" image/jpeg"];
            i++;
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failureBlock){
            failureBlock(error);
        }
    }];
}



#pragma mark - 视频上传
/**
 *  视频上传
 *
 *  @param operations     上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath      上传视频的本地沙河路径
 *  @param urlString      上传的url
 *  @param successBlock   成功的回调
 *  @param failureBlock   失败的回调
 *  @param progressBlock  上传的进度
 */
+ (void)uploadVideoWithOperaitons:(NSDictionary *)operations
                    withVideoPath:(NSString *)videoPath
                    withUrlString:(NSString *)urlString
                 withSuccessBlock:(void(^)(NSDictionary * object))successBlock
                 withFailureBlock:(void(^)(NSError *error))failureBlock
               withUploadProgress:(void(^)(float progress))progressBlock{
    /**获得视频资源*/
    AVURLAsset * avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];

    /**压缩*/
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];

    /**创建日期格式化器*/
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];

    /**转化后直接写入Library---caches*/
    NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];

    avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;

    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:
            {
                AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
                [manager POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

                    //获得沙盒中的视频内容
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoWritePath] name:@"write you want to writre" fileName:videoWritePath mimeType:@"video/mpeg4" error:nil];
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    if (progressBlock) {
                        progressBlock(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                    }
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    if (successBlock) {
                        successBlock(responseObject);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (failureBlock) {
                        failureBlock(error);
                    }
                }];
                break;
            }
            default:
                break;
        }
    }];
}

#pragma mark - 文件下载
/**
 *  文件下载
 *
 *  @param operations      文件下载预留参数---视具体情况而定 可移除
 *  @param savePath        下载文件保存路径
 *  @param urlString       请求的url
 *  @param successBlock    下载文件成功的回调
 *  @param failureBlock    下载文件失败的回调
 *  @param progressBlock   下载文件的进度显示
 */


+ (void)downLoadFileWithOperations:(NSDictionary *)operations
                      withSavaPath:(NSString *)savePath
                     withUrlString:(NSString *)urlString
                  withSuccessBlock:(void(^)(NSDictionary * object))successBlock
                  withFailureBlock:(void(^)(NSError *error))failureBlock
              withDownLoadProgress:(void(^)(float progress))progressBlock{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return  [NSURL URLWithString:savePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        }
    }];
}

#pragma mark -  取消所有的网络请求

/**
 *  取消所有的网络请求
 *  a finished (or canceled) operation is still given a chance to execute its completion block before it iremoved from the queue.
 */

+(void)cancelAllRequest {
    [[WQNetworkRequestManager shareManager].operationQueue cancelAllOperations];
}

#pragma mark -   取消指定的url请求/
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的完整url
 */

+(void)cancelHttpRequestWithRequestType:(NSString *)requestType
                       requestUrlString:(NSString *)string{
    NSError * error;
    /**根据请求的类型 以及 请求的url创建一个NSMutableURLRequest---通过该url去匹配请求队列中是否有该url,如果有的话 那么就取消该请求*/
    NSString * urlToPeCanced = [[[[WQNetworkRequestManager shareManager].requestSerializer requestWithMethod:requestType URLString:string parameters:nil error:&error] URL] path];

    for (NSOperation * operation in [WQNetworkRequestManager shareManager].operationQueue.operations) {
        //如果是请求队列
        if ([operation isKindOfClass:[NSURLSessionTask class]]) {
            //请求的类型匹配
            BOOL hasMatchRequestType = [requestType isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            //请求的url匹配
            BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            //两项都匹配的话  取消该请求
            if (hasMatchRequestType&&hasMatchRequestUrlString) {
                [operation cancel];
            }
        }
    }
}

@end
