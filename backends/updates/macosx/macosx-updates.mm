/* ScummVM - Graphic Adventure Engine
 *
 * ScummVM is the legal property of its developers, whose names
 * are too numerous to list here. Please refer to the COPYRIGHT
 * file distributed with this source distribution.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 */

// Disable symbol overrides so that we can use system headers.
#define FORBIDDEN_SYMBOL_ALLOW_ALL

#include "backends/updates/sparkle-updates.h"

#if defined(MACOSX) && defined(USE_SPARKLE)

#include "backends/updates/macosx/macosx-updates.h"
#include "common/translation.h"

#include <Cocoa/Cocoa.h>
#include <Sparkle/Sparkle.h>

SUUpdater *sparkleUpdater;

/**
 * Sparkle is a software update framework for Mac OS X which uses appcasts for
 * release information. Appcasts are RSS-like XML feeds which contain information
 * about the most current version at the time. If a new version is available, the
 * user is presented the release-notes/changes/fixes and is asked if he wants to
 * update, and if yes the Sparkle framework downloads a signed update package
 * from the server and automatically installs and restarts the software.
 * More detailed information is available at the following address:
 * http://sparkle.andymatuschak.org/
 *
 */
MacOSXUpdateManager::MacOSXUpdateManager() {
	NSMenuItem *menuItem = [[NSApp mainMenu] itemAtIndex:0];
	NSMenu *applicationMenu = [menuItem submenu];

	// Init Sparkle
	sparkleUpdater = [SUUpdater sharedUpdater];

	// Set appcast URL
	[sparkleUpdater setFeedURL:[NSURL URLWithString:[NSString stringWithCString:getAppcastUrl().c_str()]]];

	// Get current encoding
	NSStringEncoding stringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[NSString stringWithCString:(TransMan.getCurrentCharset()).c_str() encoding:NSASCIIStringEncoding]));

	// Add "Check for Updates..." menu item
	NSMenuItem *updateMenuItem = [applicationMenu insertItemWithTitle:[NSString stringWithCString:_("Check for Updates...") encoding:stringEncoding] action:@selector(checkForUpdates:) keyEquivalent:@"" atIndex:1];

	// Set the target of the new menu item
	[updateMenuItem setTarget:sparkleUpdater];

	// Finally give up our references to the objects
	[menuItem release];

	// Enable automatic update checking once a day (alternatively use
	// checkForUpdates() here to check for updates on every startup)
	// TODO: Should be removed when an update settings gui is implemented
	setAutomaticallyChecksForUpdates(kUpdateStateEnabled);
	setUpdateCheckInterval(kUpdateIntervalOneDay);
}

MacOSXUpdateManager::~MacOSXUpdateManager() {
	[sparkleUpdater release];
}

void MacOSXUpdateManager::checkForUpdates() {
	[sparkleUpdater checkForUpdatesInBackground];
}

void MacOSXUpdateManager::setAutomaticallyChecksForUpdates(UpdateManager::UpdateState state) {
	if (state == kUpdateStateNotSupported)
		return;

	[sparkleUpdater setAutomaticallyChecksForUpdates:(state == kUpdateStateEnabled ? YES : NO)];
}

Common::UpdateManager::UpdateState MacOSXUpdateManager::getAutomaticallyChecksForUpdates() {
	if ([sparkleUpdater automaticallyChecksForUpdates])
		return kUpdateStateEnabled;
	else
		return kUpdateStateDisabled;
}

void MacOSXUpdateManager::setUpdateCheckInterval(UpdateInterval interval) {
	if (interval == kUpdateIntervalNotSupported)
		return;

	[sparkleUpdater setUpdateCheckInterval:(NSTimeInterval)interval];
}

Common::UpdateManager::UpdateInterval MacOSXUpdateManager::getUpdateCheckInterval() {
	// This is kind of a hack but necessary, as the value stored by Sparkle
	// might have been changed outside of ScummVM (in which case we return the
	// default interval of one day)
	switch ((UpdateInterval)[sparkleUpdater updateCheckInterval]) {
		default:
			break;

		case kUpdateIntervalOneDay:
			return kUpdateIntervalOneDay;

		case kUpdateIntervalOneWeek:
			return kUpdateIntervalOneWeek;

		case kUpdateIntervalOneMonth:
			return kUpdateIntervalOneMonth;
	}

	// Return the default value (one day)
	return kUpdateIntervalOneDay;
}

#endif
