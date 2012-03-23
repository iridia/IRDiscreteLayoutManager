//
//  IRDiscreteLayoutGrid+Private.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 3/23/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"

@interface IRDiscreteLayoutGrid (Private)

@property (nonatomic, readonly, retain) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readonly, retain) NSArray *layoutAreaNames;
@property (nonatomic, readonly, retain) NSMutableDictionary *layoutAreaNamesToValidatorBlocks;
@property (nonatomic, readonly, retain) NSMutableDictionary *layoutAreaNamesToLayoutBlocks;
@property (nonatomic, readonly, retain) NSMutableDictionary *layoutAreaNamesToLayoutItems;
@property (nonatomic, readonly, retain) NSMutableDictionary *layoutAreaNamesToDisplayBlocks;

@end
