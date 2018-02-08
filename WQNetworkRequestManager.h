//
//  WQNetworkRequestManager.h
//  WQCocoaPodsTest
//
//  Created by 王强 on 2018/2/8.
//  Copyright © 2018年 XiYiChuanMei. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "AFNetworking.h"

/**定义请求类型的枚举*/
typedef NS_ENUM(NSUInteger,HttpRequestType){
    HttpRequestTypeGet = 0,
    HttpRequestTypePost
};

@interface WQNetworkRequestManager : AFHTTPSessionManager
/**
 *  单例方法
 *
 *  @return 实例对象
 */
+ (instancetype)shareManager;

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
               progress:(void(^)(float progress))progressBlock;

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
               withUpLoadProgress:(void(^)(float progress))progressBlock;


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
               withUploadProgress:(void(^)(float progress))progressBlock;


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
              withDownLoadProgress:(void(^)(float progress))progressBlock;

/**
 *  取消所有的网络请求
 */


+ (void)cancelAllRequest;
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的url
 */

+ (void)cancelHttpRequestWithRequestType:(NSString *)requestType
                        requestUrlString:(NSString *)string;



@end
