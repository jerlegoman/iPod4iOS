/*
 DCTTableViewDataSource.h
 DCTTableViewDataSources
 
 Created by Daniel Tull on 20.05.2011.
 
 
 
 Copyright (c) 2011 Daniel Tull. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCTTableViewDataSource.h"
#import "DCTTableViewCell.h"
#import "UITableView+DCTTableViewDataSources.h"
#import "UITableView+DCTNibRegistration.h"
#import "DCTParentTableViewDataSource.h"

@interface DCTTableViewDataSourceUpdate : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) DCTTableViewDataSourceUpdateType type;
@property (nonatomic, assign) UITableViewRowAnimation animation;
- (BOOL)isSectionUpdate;
@end

BOOL DCTTableViewDataSourceUpdateTypeIncludes(DCTTableViewDataSourceUpdateType type, DCTTableViewDataSourceUpdateType testType) {
	return (type & testType) == testType;
}

void DCTTableViewDataSourceUpdateTypeAdd(DCTTableViewDataSourceUpdateType type, DCTTableViewDataSourceUpdateType typeToAdd) {
	
	if (type == DCTTableViewDataSourceUpdateTypeUnknown)
		type = typeToAdd;
	
	type = (type | typeToAdd);
}

NSInteger const DCTTableViewDataSourceNoAnimationSet = -1912;

@implementation DCTTableViewDataSource {
	__strong NSMutableDictionary *_cellClassDictionary;	
	__strong NSMutableSet *_cellClasses;
	__strong NSMutableSet *_setupCellClasses;
	__strong NSMutableArray *_updates;
}

@synthesize tableView;
@synthesize cellClass = _cellClass;
@synthesize parent = _parent;
@synthesize sectionHeaderTitle;
@synthesize sectionFooterTitle;
@synthesize cellConfigurer;
@synthesize insertionAnimation;
@synthesize deletionAnimation;
@synthesize reloadAnimation;
@synthesize cellClassHandler = _cellClassHandler;

#pragma mark - NSObject

- (void)dealloc {
	_parent = nil;
}

- (id)init {
    
    if (!(self = [super init])) return nil;
	
	self.insertionAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.deletionAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.reloadAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.cellClass = [DCTTableViewCell class];
	_cellClassDictionary = [NSMutableDictionary new];
	_cellClasses = [NSMutableSet new];
	_setupCellClasses = [NSMutableSet new];
	
    return self;
}

#pragma mark - DCTTableViewDataSource

- (void)setCellClass:(Class)cellClass {
	_cellClass = cellClass;
	[self setupCellClass:cellClass];
}
- (void)setCellClass:(Class)cellClass forObjectClass:(Class)objectClass {
	[_cellClassDictionary setObject:cellClass forKey:NSStringFromClass(objectClass)];
	[self setupCellClass:cellClass];
}
- (Class)cellClassForObjectClass:(Class)objectClass {
	return [_cellClassDictionary objectForKey:NSStringFromClass(objectClass)];
}
- (void)setCellClass:(Class)cellClass forObject:(id)object {
	
	NSNumber *hash = [NSNumber numberWithUnsignedInteger:[object hash]];
	
	if (cellClass == NULL) {
		[_cellClassDictionary removeObjectForKey:hash];
		return;
	}
	
	[_cellClassDictionary setObject:cellClass forKey:hash];
	[self setupCellClass:cellClass];
}
- (Class)cellClassForObject:(id)object {
	return [_cellClassDictionary objectForKey:[NSNumber numberWithUnsignedInteger:[object hash]]];
}

- (void)setTableView:(UITableView *)tv {
	
	if (tv == tableView) return;
	
	tableView = tv;
	[_cellClasses enumerateObjectsUsingBlock:^(Class cellClass, BOOL *stop) {
		[self setupCellClass:cellClass];
	}];
}

- (void)reloadData {
	[self beginUpdates];
	[self enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		
		[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowReload
					 indexPath:indexPath
					 animation:self.reloadAnimation];
		
	}];
	[self endUpdates];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
	
	id object = [self objectAtIndexPath:indexPath];
	
	Class cellClass = NULL;
	
	if (self.cellClassHandler != NULL) {
		cellClass = self.cellClassHandler(indexPath, object);
		if (cellClass != NULL) {
			[self setupCellClass:cellClass];
			return cellClass;
		}
	}
	
	cellClass = [self cellClassForObject:object];
	if (cellClass != NULL) return cellClass;
	
	cellClass = [self cellClassForObjectClass:[object class]];
	if (cellClass != NULL) return cellClass;
	
	return self.cellClass;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {}


#pragma mark - Updating the table view

- (void)beginUpdates {
	
	if (self.parent) {
		[self.parent beginUpdates];
		return;
	}
	
	_updates = [NSMutableArray new];
}

- (void)endUpdates {
	[self _endUpdates:self.reloadType];
	_updates = nil;
}

- (void)_endUpdates:(DCTTableViewDataSourceReloadType)reloadType {
	
	if (self.parent)
		[self.parent _endUpdates:reloadType];
	
	else if (reloadType == DCTTableViewDataSourceReloadTypeDefault)
		[self _endUpdatesDefault];
	else
		[self _endUpdatesNonDefault:reloadType];
}

- (void)_endUpdatesDefault {
		
	[self.tableView beginUpdates];
	
	[_updates enumerateObjectsUsingBlock:^(DCTTableViewDataSourceUpdate *update, NSUInteger i, BOOL *stop) {
		
		if (update.animation == DCTTableViewDataSourceNoAnimationSet)
			update.animation = DCTTableViewDataSourceTableViewRowAnimationAutomatic;
		
		switch (update.type) {
			
			case DCTTableViewDataSourceUpdateTypeRowInsert:
				[self.tableView insertRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;
			
			case DCTTableViewDataSourceUpdateTypeRowDelete:
				[self.tableView deleteRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;
				
			case DCTTableViewDataSourceUpdateTypeRowReload:
				[self.tableView reloadRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;
				
			case DCTTableViewDataSourceUpdateTypeSectionInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
				break;
				
			case DCTTableViewDataSourceUpdateTypeSectionDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
				break;
				
			default:
				break;
		}
	}];
	
	[self.tableView endUpdates];
}

- (void)_endUpdatesNonDefault:(DCTTableViewDataSourceReloadType)reloadType {
	
	NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
		
	if ([indexPaths count] == 0) {
		[self.tableView reloadData];
		return;
	}
	
	__block NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
	if (reloadType == DCTTableViewDataSourceReloadTypeBottom)
		indexPath = [indexPaths lastObject];
	
	CGFloat firstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;
	
	NSArray *updates = [_updates sortedArrayUsingSelector:@selector(compare:)];
			
	[updates enumerateObjectsUsingBlock:^(DCTTableViewDataSourceUpdate *update, NSUInteger i, BOOL *stop) {
				
		if ([update.indexPath compare:indexPath] == NSOrderedDescending) {
			*stop = YES;
			return;
		}
		
		switch (update.type) {
				
			case DCTTableViewDataSourceUpdateTypeRowInsert:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
				break;
				
			case DCTTableViewDataSourceUpdateTypeRowDelete:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
				break;
				
			case DCTTableViewDataSourceUpdateTypeSectionInsert:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
				break;
				
			case DCTTableViewDataSourceUpdateTypeSectionDelete:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
				break;
				
			default:
				break;
		}
	}];
			
	[self.tableView reloadData];
			
	CGFloat newFirstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;
			
	CGPoint offset = self.tableView.contentOffset;
	offset.y += (newFirstVisibleCellYPosition - firstVisibleCellYPosition);
	self.tableView.contentOffset = offset;
}

- (void)_performUpdate:(DCTTableViewDataSourceUpdate *)update {
	
	if (update.animation == DCTTableViewDataSourceNoAnimationSet) {
		
		switch (update.type) {
			case DCTTableViewDataSourceUpdateTypeRowInsert:
			case DCTTableViewDataSourceUpdateTypeSectionInsert:
				update.animation = self.insertionAnimation;
				break;
				
			case DCTTableViewDataSourceUpdateTypeRowDelete:
			case DCTTableViewDataSourceUpdateTypeSectionDelete:
				update.animation = self.deletionAnimation;
				break;
				
			case DCTTableViewDataSourceUpdateTypeRowReload:
				update.animation = self.reloadAnimation;
				break;
				
			default:
				break;
		}
	}
	
	if (self.parent) {
		
		if ([update isSectionUpdate]) {
			update.section = [self.parent convertSection:update.section fromChildTableViewDataSource:self];
			[self.parent _performUpdate:update];
			return;
		}
		
		update.indexPath = [self.parent convertIndexPath:update.indexPath fromChildTableViewDataSource:self];
		[self.parent _performUpdate:update];
		return;
	}
	
	[_updates addObject:update];
}

- (void)performSectionUpdate:(DCTTableViewDataSourceUpdateType)updateType
				sectionIndex:(NSInteger)index
				   animation:(UITableViewRowAnimation)animation {
	
	DCTTableViewDataSourceUpdate *update = [DCTTableViewDataSourceUpdate new];
	update.animation = animation;
	update.type = updateType;
	update.section = index;
	[self _performUpdate:update];
}

- (void)performRowUpdate:(DCTTableViewDataSourceUpdateType)updateType
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	DCTTableViewDataSourceUpdate *update = [DCTTableViewDataSourceUpdate new];	
	update.animation = animation;
	update.type = updateType;
	update.indexPath = indexPath;
	[self _performUpdate:update];
}

- (void)enumerateIndexPathsUsingBlock:(void(^)(NSIndexPath *, BOOL *stop))enumerator {
	
	NSInteger sectionCount = [self numberOfSectionsInTableView:self.tableView];
	
	for (NSInteger section = 0; section < sectionCount; section++) {
		
		NSInteger rowCount = [self tableView:self.tableView numberOfRowsInSection:section];
		
		for (NSInteger row = 0; row < rowCount; row++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
			BOOL stop = NO;
			enumerator(indexPath, &stop);
			if (stop) return;
		}
	}	
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = nil;
	
	Class theCellClass = [self cellClassAtIndexPath:indexPath];
	
	if ([theCellClass isSubclassOfClass:[DCTTableViewCell class]])
		cellIdentifier = [theCellClass reuseIdentifier];
	
    UITableViewCell *cell = [tv dct_dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell && [theCellClass isSubclassOfClass:[DCTTableViewCell class]])
		cell = [theCellClass cell];
	
	if (!cell)
		cell = [[theCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
	id object = [self objectAtIndexPath:indexPath];
	
	[self configureCell:cell atIndexPath:indexPath withObject:object];
	
	if ([cell conformsToProtocol:@protocol(DCTTableViewCellObjectConfiguration)])
		[(id<DCTTableViewCellObjectConfiguration>)cell configureWithObject:object];
	
	if (self.cellConfigurer != NULL) self.cellConfigurer(cell, indexPath, object);
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.sectionFooterTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sectionHeaderTitle;
}

#pragma mark - Internal

- (void)setupCellClass:(Class)cellClass {
	
	[_cellClasses addObject:cellClass];
	
	if (!self.tableView) return;
	
	if ([_setupCellClasses containsObject:cellClass]) return;
	
	[_setupCellClasses addObject:cellClass];
	
	if (![cellClass isSubclassOfClass:[DCTTableViewCell class]]) return;
	
	NSString *nibName = [cellClass nibName];
	
	if ([nibName length] < 1) return;
	
	UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
	NSString *reuseIdentifier = [cellClass reuseIdentifier];
	
	[self.tableView dct_registerNib:nib forCellReuseIdentifier:reuseIdentifier];
}

@end



@implementation DCTTableViewDataSourceUpdate

- (BOOL)isSectionUpdate {
	return (DCTTableViewDataSourceUpdateTypeIncludes(self.type, DCTTableViewDataSourceUpdateTypeSectionInsert)
			|| DCTTableViewDataSourceUpdateTypeIncludes(self.type, DCTTableViewDataSourceUpdateTypeSectionDelete));
}

- (NSComparisonResult)compare:(DCTTableViewDataSourceUpdate *)update {
	
	NSComparisonResult result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:update.type]];
	
	if (result != NSOrderedSame) return result;
	
	return [self.indexPath compare:update.indexPath];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; indexPath = %@; type = %i; animation = %i>",
			NSStringFromClass([self class]),
			self,
			self.indexPath,
			self.type,
			self.animation];
}

@end
