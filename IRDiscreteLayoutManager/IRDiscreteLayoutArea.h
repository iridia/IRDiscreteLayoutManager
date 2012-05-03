//
//  IRDiscreteLayoutArea.h
//  IRDiscreteLayoutManager
//
//  Created by Evadne Wu on 5/2/12.
//  Copyright (c) 2012 Iridia Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRDiscreteLayoutItem.h"

@class IRDiscreteLayoutArea, IRDiscreteLayoutGrid;

#ifndef __IRDiscreteLayoutArea__
#define __IRDiscreteLayoutArea__

typedef BOOL (^IRDiscreteLayoutAreaValidatorBlock) (IRDiscreteLayoutArea *self, id item);
typedef CGRect (^IRDiscreteLayoutAreaLayoutBlock) (IRDiscreteLayoutArea *self, id item);
typedef id (^IRDiscreteLayoutAreaDisplayBlock) (IRDiscreteLayoutArea *self, id item);

#endif	/* __IRDiscreteLayoutArea__ */

@interface IRDiscreteLayoutArea : NSObject <NSCopying>

- (id) initWithIdentifier:(NSString *)identifier;

@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, strong) id<IRDiscreteLayoutItem> item;

- (BOOL) setItem:(id<IRDiscreteLayoutItem>)item error:(NSError **)outError;

@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaValidatorBlock validatorBlock;
@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaLayoutBlock layoutBlock;
@property (nonatomic, readwrite, copy) IRDiscreteLayoutAreaDisplayBlock displayBlock;

@property (nonatomic, readwrite, weak) IRDiscreteLayoutGrid *grid;

@end
