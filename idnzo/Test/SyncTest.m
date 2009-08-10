//
//  SyncTest.m
//  DNZO
//
//  Created by Taylor Hughes on 8/9/09.
//  Copyright 2009 Nemean Networks. All rights reserved.
//

#import "SyncTest.h"

@implementation SyncTest

// Makes sure we properly sync remote and local task lists.
//
- (void) testMergeTaskLists
{
}

// Tests the case where we have a remote list called "Tasks"
// and a local list called "Tasks", and when we sync the first
// time the local app uses the name to reconcile the remote and
// local lists.
//
- (void) testReconcileTaskLists
{
}

// Makes sure we properly handle the case when we have new
// tasks both locally and remotely.
//
- (void) testNewTasksRemoteAndLocal
{
}

// Tests to make sure we sync existing tasks to get remote
// changes and that local changes are saved remotely.
//
- (void) testUpdatedTasks
{
}

// Tests to make sure we properly handle the case where
// a task was updated remotely and locally, so we choose the
// latest one.
//
- (void) testUpdatedTasksWithConflict
{
}

@end
