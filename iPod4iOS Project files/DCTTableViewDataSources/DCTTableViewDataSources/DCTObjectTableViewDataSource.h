/*
 DCTObjectTableViewDataSource.h
 DCTTableViewDataSources
 
 Created by Daniel Tull on 19.09.2011.
 
 
 
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

/** A simple, perhaps the most simple, data source class. It gives back one 
 section and one row, displaying a cell with the given represented object.
 
 For example if you wanted a default cell, with the text "Hello world!" to 
 appear in your table view, you would write this:
 
	DCTObjectTableViewDataSource *ds = [[DCTObjectTableViewDataSource alloc] init];
	ds.object = @"Hello world!";
	tableview.dataSource = ds;
 
 If you want a custom cell, you just assign its class to the cellClass property
 and an instance of that class will be created, if it conforms to 
 DCTTableViewCellObjectConfiguration, then it will get a message to 
 [configureWithObject:]([DCTTableViewCell configureWithObject:]) with the
 given object for you to set up with.
 */
@interface DCTObjectTableViewDataSource : DCTTableViewDataSource

/** The represented object for the single cell in this data soruce.
 */
@property (nonatomic, strong) id object;
@end
