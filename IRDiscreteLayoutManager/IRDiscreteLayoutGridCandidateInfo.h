//
//  IRDiscreteLayoutGridCandidateInfo.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 4/25/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRDiscreteLayoutGrid.h"

//	This is a private class used by the Layout Manager to store information related to a Layout Grid candidate during relayout
//	and should never be used directly elsewhere.

@interface IRDiscreteLayoutGridCandidateInfo : NSObject

+ (id) infoWithGrid:(IRDiscreteLayoutGrid *)gridInstance itemIndices:(NSIndexSet *)gridItemIndices referenceGrid:(IRDiscreteLayoutGrid *)referenceGridInstance delegateIndex:(NSUInteger)index;

@property (nonatomic, readonly, unsafe_unretained) IRDiscreteLayoutGrid *grid;
@property (nonatomic, readonly, strong) NSIndexSet *itemIndices;
@property (nonatomic, readonly, unsafe_unretained) IRDiscreteLayoutGrid *referenceGrid;
@property (nonatomic, readonly, assign) CGFloat score;
@property (nonatomic, readonly, assign) NSUInteger delegateIndex;

@end
