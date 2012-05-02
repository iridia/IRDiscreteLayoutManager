//
//  IRDiscreteLayoutGrid.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

@protocol IRDiscreteLayoutItem;
@class IRDiscreteLayoutGrid, IRDiscreteLayoutItem, IRDiscreteLayoutArea;

@interface IRDiscreteLayoutGrid : NSObject <NSCopying>

- (id) initWithIdentifier:(NSString *)gridID contentSize:(CGSize)size layoutAreas:(NSArray *)areas;

@property (nonatomic, readonly, copy) NSString *identifier;
@property (nonatomic, readonly, weak) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readonly, strong) NSArray *layoutAreas;
@property (nonatomic, readwrite, assign) CGSize contentSize;

- (IRDiscreteLayoutGrid *) instanceWithItems:(NSArray *)items error:(NSError **)outError;
+ (BOOL) canInstantiateGrid:(IRDiscreteLayoutGrid *)instance withItems:(NSArray *)providedItems error:(NSError **)outError;

- (IRDiscreteLayoutArea *) areaWithIdentifier:(NSString *)identifier;
- (IRDiscreteLayoutArea *) areaForItem:(id<IRDiscreteLayoutItem>)item;
- (NSArray *) items;

@end
