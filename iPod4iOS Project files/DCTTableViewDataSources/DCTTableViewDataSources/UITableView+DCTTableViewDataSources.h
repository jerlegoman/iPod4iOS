/*
 UITableView+DCTTableViewDataSources.h
 DCTTableViewDataSources
 
 Created by Daniel Tull on 08.10.2011.
 
 
 
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

#import <UIKit/UIKit.h>
@class DCTTableViewDataSource;

@interface UITableView (DCTTableViewDataSources)

/** @name Logging */

/** Logs the hierarchy of the table view data sources.
 
 This is done by traversing the childTableViewDataSources of the parent
 data sources as it goes down. 
 */
- (void)dct_logTableViewDataSources;

/** @name Conversion methods */


/** Returns the section, with respect to the table view, of a section in
 the given child data source's structure. This uses the conversion
 methods of the DCTTableViewDataSources.
 
 @param section The section in the given data source's co-ordinate space.
 @param dataSource The data source to convert the section from.
 
 @return The section in the table view's co-ordinate space.
 */
- (NSInteger)dct_convertSection:(NSInteger)section fromChildTableViewDataSource:(DCTTableViewDataSource *)dataSource;

/** Returns the indexPath, with respect to the table view, of an index path 
 in the given child data source's structure. This uses the conversion methods
 of the DCTTableViewDataSources.
 
 @param indexPath The index path in the given data source's co-ordinate space.
 @param dataSource The data source to convert the index path from.
 
 @return The index path in the table view's co-ordinate space.
 */
- (NSIndexPath *)dct_convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(DCTTableViewDataSource *)dataSource;

/** @name Cell registration */

/** Uses the iOS 5 method to register a table view cell class with a nib.
 This will only work for DCTTableViewCell subclasses, but won't crash for 
 others. If iOS 5 is not available, this method does nothing.
 
 @param tableViewCellSubclass The DCTTableViewCell subclass of the cell to register.
 
 @deprecated This method does nothing.
 */
- (void)dct_registerDCTTableViewCellSubclass:(Class)tableViewCellSubclass;

@end