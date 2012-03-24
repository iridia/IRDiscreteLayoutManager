//
//  IRDiscreteLayoutGrid.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 8/27/11.
//  Copyright 2011 Iridia Productions. All rights reserved.
//

@protocol IRDiscreteLayoutItem;
@class IRDiscreteLayoutArea, IRDiscreteLayoutItem;


extern NSString * const IRDiscreteLayoutGridErrorDomain;
extern NSUInteger IRDiscreteLayoutGridValidationFailureError;


@protocol IRDiscreteLayoutGrid <NSObject, NSCopying>

@property (nonatomic, readonly, assign) CGSize contentSize;
@property (nonatomic, readonly, copy) NSArray *areas;

@end


@interface IRDiscreteLayoutGridPrototype : NSObject <IRDiscreteLayoutGrid>

+ (id) prototypeWithAreas:(NSArray *)areas;
- (id) initWithAreas:(NSArray *)areas;

- (id) instantiateWithItems:(NSArray *)items options:(NSUInteger)options error:(NSError **)error;

@property (nonatomic, readwrite, copy) BOOL (^populationInspectorBlock)(IRDiscreteLayoutGridPrototype *self);

@end


@interface IRDiscreteLayoutGridInstance : NSObject <IRDiscreteLayoutGrid>

@property (nonatomic, readonly, retain) IRDiscreteLayoutGridPrototype *prototype;
@property (nonatomic, readonly, assign, getter=isFullyPopulated) BOOL fullyPopulated;

@end

