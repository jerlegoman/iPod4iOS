//
//  DCTInterspersedTableViewDataSource.h
//  Tweetville
//
//  Created by Daniel Tull on 23.05.2012.
//  Copyright (c) 2012 Daniel Tull Limited. All rights reserved.
//

#import "DCTParentTableViewDataSource.h"

@interface DCTInterspersedTableViewDataSource : DCTParentTableViewDataSource
/** The child data source to intersperse.
 */
@property (nonatomic, strong) DCTTableViewDataSource *childTableViewDataSource;
@property (nonatomic, assign) Class interspersedCellClass;

@end
