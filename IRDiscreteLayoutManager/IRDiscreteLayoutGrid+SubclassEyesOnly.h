//
//  IRDiscreteLayoutGrid+SubclassEyesOnly.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import "IRDiscreteLayoutGrid.h"

@interface IRDiscreteLayoutGrid (SubclassEyesOnly)

@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, weak) IRDiscreteLayoutGrid *prototype;
@property (nonatomic, readwrite, strong) NSArray *layoutAreas;

@end
