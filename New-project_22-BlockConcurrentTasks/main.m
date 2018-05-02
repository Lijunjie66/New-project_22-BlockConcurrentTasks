//
//  main.m
//  New-project_22-BlockConcurrentTasks
//
//  Created by Geraint on 2018/5/2.
//  Copyright © 2018年 kilolumen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define YahooURL  @"http://www.yahoo.com/index.html"
#define ApressURL @"http://www.apress.com/index.html"


//
typedef void (^DownloadURL)(void);

/*
 
 该函数会返回用于下载URL的  块常量 （异步任务）
 
 */
// 获取用于下载URL的块
DownloadURL getDownloadURLBlock(NSString *url) {
    
    NSString *urlString = url;
    return ^{
        // 下载URL
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        NSError *error;
        NSDate *startTime = [NSDate date];
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        
        if (data == nil) {
            NSLog(@"Error loading request %@", [error localizedDescription]);
        } else {
            NSDate *endTime = [NSDate date];
            NSTimeInterval timeInterval = [endTime timeIntervalSinceDate:endTime];
            NSLog(@"Time taken to download %@ = %f seconds", urlString, timeInterval);
        }
        
    };
}


int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        // 创建任务请求（ ***    为了以并行方式执行任务，创建了两个  全局并发分派队列 ）
        dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t queue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 创建任务分组 （ ***   任务组用于对任务进行编组、为执行异步操作对任务进行排队、等待以排队的任务组等 ）
        dispatch_group_t group = dispatch_group_create();
        
        // 获取度量的当前时间
        NSDate *startTime = [NSDate date];
        
        // 创建并分派异步任务（GCD）
        dispatch_group_async(group, queue1, getDownloadURLBlock(YahooURL));
        dispatch_group_async(group, queue2, getDownloadURLBlock(ApressURL));
        
        // 等待，直到分组中的所有任务完成为止 （主进程等待，直到任务完成为止）
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        // 为并行操作和日志检索时间信息 （完成两个任务所消耗的时间）
        NSDate *endTime = [NSDate date];
        NSTimeInterval timeInterval = [endTime timeIntervalSinceDate:startTime];
        NSLog(@"Time takan to download URLs concrrently = %f second", timeInterval);
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
