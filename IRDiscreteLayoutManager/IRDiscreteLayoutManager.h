//
//  IRDiscreteLayoutManager.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/26/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutItem.h"
#import "IRDiscreteLayoutGrid.h"
#import "IRDiscreteLayoutGrid+Transforming.h"
#import "IRDiscreteLayoutResult.h"

@class IRDiscreteLayoutManager;


enum {
	IRRandomLayoutStrategy = 1,
	IRCompareScoreLayoutStrategy,
	IRDefaultLayoutStrategy = IRRandomLayoutStrategy
}; typedef NSUInteger IRDiscreteLayoutStrategy;


@protocol IRDiscreteLayoutManagerDataSource <NSObject>

- (NSUInteger) numberOfItemsForLayoutManager:(IRDiscreteLayoutManager *)manager;
- (id<IRDiscreteLayoutItem>) layoutManager:(IRDiscreteLayoutManager *)manager itemAtIndex:(NSUInteger)index;
- (NSInteger) layoutManager:(IRDiscreteLayoutManager *)manager indexOfLayoutItem:(id<IRDiscreteLayoutItem>)item;

@end


@protocol IRDiscreteLayoutManagerDelegate <NSObject>

- (NSUInteger) numberOfLayoutGridsForLayoutManager:(IRDiscreteLayoutManager *)manager;
- (IRDiscreteLayoutGrid *) layoutManager:(IRDiscreteLayoutManager *)manager layoutGridAtIndex:(NSUInteger)index;
- (NSInteger) layoutManager:(IRDiscreteLayoutManager *)manager indexOfLayoutGrid:(IRDiscreteLayoutGrid *)grid;

@optional

- (NSArray *) layoutManager:(IRDiscreteLayoutManager *)manager targetItemsForProposedItems:(NSArray *)proposedItems instantiatingGrid:(IRDiscreteLayoutGrid *)prototype addedToResult:(IRDiscreteLayoutResult *)interimResult replacingGrid:(IRDiscreteLayoutGrid *)replacedGrid inReference:(IRDiscreteLayoutResult *)lastResult;

- (IRDiscreteLayoutGrid *) layoutManager:(IRDiscreteLayoutManager *)manager targetForProposedGrid:(IRDiscreteLayoutGrid *)proposedGrid amongCandidates:(NSArray *)candidatesSortedByScore addedToResult:(IRDiscreteLayoutResult *)interimResult replacingGrid:(IRDiscreteLayoutGrid *)replacedGrid inReference:(IRDiscreteLayoutResult *)lastResult;

@end


@interface IRDiscreteLayoutManager : NSObject

@property (nonatomic, readwrite, unsafe_unretained) id<IRDiscreteLayoutManagerDataSource> dataSource;
@property (nonatomic, readwrite, unsafe_unretained) id<IRDiscreteLayoutManagerDelegate> delegate;

- (IRDiscreteLayoutResult *) calculatedResultWithReference:(IRDiscreteLayoutResult *)lastResult strategy:(IRDiscreteLayoutStrategy)strategy error:(NSError **)outError;
- (IRDiscreteLayoutResult *) calculatedResult;	//	For lazy people.

@end
