/*
 DCTCoreDataStack.h
 DCTCoreDataStack
 
 Created by Daniel Tull on 01.12.2011.
 
 
 
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


// DCTCoreDataStack is intended for non-document based apps, and provides the following features:
//
// 1) An encapsulation of the complete Core Data stack of NSManagedObjectContext, NSPersistentStoreCoordinator, NSPersistentStore, and NSManagedObjectModel
//
// 2) On new enough OS's that support it, writing to disk is performed on a background thread, by using a parent context. Saving the main context automatically triggers saving the parent context asynchronously
//
// 3) -[NSManagedObjectContext dct_saveWithCompletionHandler:] method can be used to be notified when saving to disk finishes, asynchronously if possible
//
// 4) On iOS, the app entering the background, or terminating, automatically triggers a save if needed. You can be notified of such saves by setting the .automaticSaveCompletionHandler property
//
// 5) On iOS, when saving on a background thread, the stack protects against termination/suspension by declaring the save as a background task
//
// 6) Generation of private queue managed object contexts via -[DCTCoreDataStack newWorkerManagedObjectContext]. Saving this causes a save to disk and a merge to the context in managedObjectContext

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+DCTCoreDataStack.h"

#ifndef dctcoredatastack
#define dctcoredatastack_1_0     10000
#define dctcoredatastack         dctcoredatastack_1_0
#endif

// Return YES if the error was resolved
typedef BOOL (^DCTCoreDataStackPersistentStoreErrorResolutionBlock) (NSError *error);


@interface DCTCoreDataStack : NSObject

// Convenience that assumes XML store, nil config, no options. The model is made up by merging all in the app's main bundle
// Generally the best method to use when getting started
- (id)initWithStoreFilename:(NSString *)filename;

// This method is helpful for when your app has previously been using -initWithStoreFilename: but now needs to migrate an existing store. To do so, specify the name of the *new* model; set the options values corresponding to both the NSMigratePersistentStoresAutomaticallyOption and the NSInferMappingModelAutomaticallyOption keys to YES. For more details see Apple's Core Data versioning and migration guide.
- (id)initWithStoreURL:(NSURL *)storeURL
			 storeType:(NSString *)storeType
		  storeOptions:(NSDictionary *)storeOptions
	modelConfiguration:(NSString *)modelConfiguration
			  modelURL:(NSURL *)modelURL;

@property (nonatomic, copy) DCTCoreDataStackPersistentStoreErrorResolutionBlock didResolvePersistentStoreErrorHandler;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

/** Generates a new private context to do background work on.
 
 This is a sibling to the managedObjectContext and saves to this context will merge across
 to the managedObjectContext. Changes to the managedObjectContext will not merge across
 to the context given from this method, and should be handled by the user if desired.
 */
- (NSManagedObjectContext *)newWorkerManagedObjectContext;

@property (nonatomic, copy, readonly) NSURL *storeURL;
@property (nonatomic, copy, readonly) NSString *storeType;
@property (nonatomic, copy, readonly) NSDictionary *storeOptions;
@property (nonatomic, copy, readonly) NSString *modelConfiguration;
@property (nonatomic, copy, readonly) NSURL *modelURL;

#ifdef TARGET_OS_IPHONE
@property (nonatomic, copy) void(^automaticSaveCompletionHandler)(BOOL success, NSError *error);
#endif

@end
