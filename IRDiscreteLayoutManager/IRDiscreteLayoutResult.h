//
//  IRDiscreteLayoutResult.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRDiscreteLayoutResult : NSObject

+ (IRDiscreteLayoutResult *) resultWithGrids:(NSArray *)grids;
- (IRDiscreteLayoutResult *) initWithGrids:(NSArray *)grids;

@property (nonatomic, readonly, retain) NSArray *grids;

@end
