//
//  SFCommonFounction.m
//  CAMTOOL
//
//  Created by jifu on 11/16/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFCommonFounction.h"
#include "tcpconnect.h"
@implementation SFCommonFounction

+(BOOL)checkNetworkConnection:(NSString *)ip;
{
 //FIXME: Need to be overwrite in future.
    if (check_network_connection(ip.UTF8String, 2000) != 1  ) {
        return NO;
    }
    return YES;
}


+(NSString *)executeCmd:(NSString *)cmd withArguments:(NSArray *)arguments{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath: cmd];
    [task setArguments: arguments];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];

    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

+(int)executeShell:(NSString *)commond parseOutputDataUsingBlock:(void (^)(NSData *data))blk;
{
    int status=0;
    @autoreleasepool {
        NSTask * task = [[NSTask alloc] init];
        [task setLaunchPath: @"/bin/sh"];
        
        NSArray *arguments = [NSArray arrayWithObjects:
                              @"-c" ,
                              [NSString stringWithFormat:@"%@", commond],
                              nil];
        //NSLog(@"run command: %@",commond);
        [task setArguments: arguments];
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput: pipe];
        @try {
            [task launch];
            [task waitUntilExit];
            if (blk !=NULL)
            {
                NSFileHandle *file = [pipe fileHandleForReading];
                NSData * data = [file readDataToEndOfFile];
                blk(data);
            }
            
        }
        @catch (NSException *exception) {
            status = -1;
        }
        status = [task terminationStatus];
    }
    
    return status;
}

+(NSString *)getSubStringFromString:(NSString *)aString withPattern:(NSString *)pattern;
{
    if (aString == nil || pattern == nil) {
        return nil;
    }
    NSString *str=nil;
    NSRegularExpression *regExp=[NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    @try {
        NSArray *matches =[ regExp matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
        
        for (NSTextCheckingResult *match in matches) {
            NSRange firstHalfRange = [match rangeAtIndex:1];
            str = [aString    substringWithRange:firstHalfRange];
            break;
        }
    }
    @catch (NSException *exception) {
        
        NSLog(@"<Exception> getStringWithPattern");
    }
    return str;
}

+(NSString *)stringToMD5Value:(NSString *)str
{
    if (str == nil) {
        return nil;
    }
    __block NSString *output=nil;
    [self executeShell:[NSString stringWithFormat:@"md5 -s \"%@\"",str] parseOutputDataUsingBlock:^(NSData *data) {
        output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        
    }];
    return [self getSubStringFromString:output withPattern:@"=\\s*(\\w+)$"];
    
}

//MARK:No using.
+(void)sendJsonData:(NSDictionary *)data
              toURL:(NSString *)url
         withMethod:(NSString *)method
  completionHandler:(void (^)(NSData * jsonData))blk;
{
    NSURL *jsonURL = [NSURL URLWithString:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:jsonURL];
    [request setTimeoutInterval:10];
    [request setHTTPMethod:method];
    // [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    //[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];//请求头
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];;
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request addValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];

    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *  data, NSURLResponse *  response, NSError *  error) {
        
        if (!data) {
            NSLog(@"Error connecting: %@", [error localizedDescription]);
            return;
        }
        
        blk(data);

    }];
    [task resume];


}
@end
