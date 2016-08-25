//
//  SFDataCenter.m
//  CAMTOOL
//
//  Created by jifu on 1/24/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFDataCenter.h"

@implementation SFDataCenter
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel ;

+(instancetype)sharedDataCenter;
{
    static dispatch_once_t onceToken;
    static SFDataCenter *sharedDataCenter = nil;
    dispatch_once(&onceToken, ^{
        sharedDataCenter=[SFDataCenter new];
    });
    return sharedDataCenter;
}

-(NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SFDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil  ) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL =[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SiFOCoreData.db"];
    NSError *error = nil;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    if (! [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}
-(NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator =[self persistentStoreCoordinator];
    if (coordinator !=nil) {
        _managedObjectContext =[NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

-(void)saveContext;
{
    NSError *anyError= nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&anyError]) {
        NSLog(@"Unresolved error %@,%@",anyError,[anyError userInfo]);
        abort();

    }
}

-(NSURL *)applicationDocumentsDirectory;
{
    NSURL *documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"com.sifo-ltd.camtool"];
    if (! [[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory path]]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return documentsDirectory;
}
@end
