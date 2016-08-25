//
//  SFCommonFounction.h
//  CAMTOOL
//
//  Created by jifu on 11/16/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFCommonFounction : NSObject
+(NSString *)executeCmd:(NSString *)cmd withArguments:(NSArray *)arguments;
+(BOOL)checkNetworkConnection:(NSString *)ip;
+(NSString *)stringToMD5Value:(NSString *)str;
+(int)executeShell:(NSString *)commond parseOutputDataUsingBlock:(void (^)(NSData *data))blk;
+(NSString *)getSubStringFromString:(NSString *)aString withPattern:(NSString *)pattern;

+(void)sendJsonData:(NSDictionary *)data
              toURL:(NSString *)url
         withMethod:(NSString *)method
  completionHandler:(void (^)(NSData * jsonData))blk;

@end
