//
//  SFDataCenter.h
//  CAMTOOL
//
//  Created by jifu on 1/24/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,SFLogType){
    SFLogTypeNormal,
    SFLogTypeWarning,
    SFLogTypeError
};

typedef NS_ENUM(NSInteger,SFUUTTestResult){
    SFUUTPassedResult,
    SFUUTFailedResult,
    SFUUTAbortedResult
};

@interface SFDataCenter : NSObject

@property(readonly,strong,nonatomic)NSManagedObjectContext *managedObjectContext;
@property(readonly,strong,nonatomic)NSManagedObjectModel *managedObjectModel;
@property(readonly,strong,nonatomic)NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSURL *)applicationDocumentsDirectory;

+(instancetype)sharedDataCenter;

@end
