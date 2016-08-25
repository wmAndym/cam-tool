//
//  NavigationItem.h
//  CAM
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef enum _ItemCellType
{
    OTHER_ITEM_TYPE = 0 ,
    ROBOT_ITEM_TYPE = 1,
    FIXTRUE_ITEM_TYPE =2,
    CNV_ITEM_TYPE =3
    
}ItemCellType;


@interface NavigationItem : NSObject
@property(assign)BOOL isLeaf;
@property(copy)NSString *name;
@property(copy)NSString *nibName;
@property(copy)NSString *iconName;
@property(copy)NSString *owner;
@property(nonatomic)ItemCellType itemType;
@property(copy)NSNumber *minorUserLevel;
@property(retain)NSMutableArray *children;

+(NSMutableArray *)rootItems;
@end
