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
 
#include "pegasus/graphics.h"

#include "common/endian.h"
#include "common/file.h"
#include "common/textconsole.h"
#include "engines/util.h"

namespace Pegasus {
	
GraphicsManager::GraphicsManager(PegasusEngine *vm) : _vm(vm) {
	initGraphics(640, 480, true, NULL);
	
	_pictDecoder = new Graphics::PictDecoder(_vm->_system->getScreenFormat());

	for (int i = 0; i < kImageCacheSize; i++)
		_cache[i].surface = 0;
}
	
GraphicsManager::~GraphicsManager() {
	delete _pictDecoder;

	for (int i = 0; i < kImageCacheSize; i++) {
		if (_cache[i].surface) {
			_cache[i].surface->free();
			delete _cache[i].surface;
		}
	}
}

Graphics::Surface *GraphicsManager::decodeImage(const Common::String &filename) {
	int imageSlot = getImageSlot(filename);

	if (_cache[imageSlot].surface)
		return _cache[imageSlot].surface;

	Common::File file;
	if (!file.open(filename))
		error("Could not open \'%s\'", filename.c_str());

	byte palette[256 * 3];
	Graphics::Surface *image = _pictDecoder->decodeImage(&file, palette);

	// For <= 8bpp, we need to convert
	if (image->format.bytesPerPixel == 1) {
		Graphics::PixelFormat format = _vm->_system->getScreenFormat();
		Graphics::Surface *output = new Graphics::Surface();
		output->create(image->w, image->h, format);

		for (uint16 y = 0; y < image->h; y++) {
			for (uint16 x = 0; x < image->w; x++) {
				byte c = *((byte *)image->getBasePtr(x, y));
				byte r = palette[c * 3];
				byte g = palette[c * 3 + 1];
				byte b = palette[c * 3 + 2];

				if (format.bytesPerPixel == 2) {
					uint16 color = format.RGBToColor(r, g, b);
					memcpy(output->getBasePtr(x, y), &color, 2);
				} else if (format.bytesPerPixel == 4) {
					uint32 color = format.RGBToColor(r, g, b);
					memcpy(output->getBasePtr(x, y), &color, 4);
				}
			}
		}

		image->free();
		delete image;
		image = output;
	}

	_cache[imageSlot].surface = image;
	return image;
}

void GraphicsManager::drawPict(Common::String filename, int x, int y, bool updateScreen) {
	Graphics::Surface *surface = decodeImage(filename);
	
	_vm->_system->copyRectToScreen((byte *)surface->pixels, surface->pitch, x, y, surface->w, surface->h);

	if (updateScreen)
		_vm->_system->updateScreen();
}

void GraphicsManager::drawPictTransparent(Common::String filename, int x, int y, uint32 transparency, bool updateScreen) {
	if (_vm->_system->getScreenFormat().bytesPerPixel == 2)
		transparency &= 0xffff;

	Graphics::Surface *surface = decodeImage(filename);
	Graphics::Surface *screen = _vm->_system->lockScreen();

	for (uint16 i = 0; i < surface->h; i++) {
		for (uint16 j = 0; j < surface->w; j++) {
			if (_vm->_system->getScreenFormat().bytesPerPixel == 2) {
				uint16 color = *((uint16 *)surface->getBasePtr(j, i));
				if (color != transparency)
					memcpy(screen->getBasePtr(j + x, i + y), &color, 2);
			} else if (_vm->_system->getScreenFormat().bytesPerPixel == 4) {
				uint32 color = *((uint32 *)surface->getBasePtr(j, i));
				if (color != transparency)
					memcpy(screen->getBasePtr(j + x, i + y), &color, 4);
			}
		}
	}

	_vm->_system->unlockScreen();

	if (updateScreen)
		_vm->_system->updateScreen();
}

uint32 GraphicsManager::getColor(byte r, byte g, byte b) {
	return _vm->_system->getScreenFormat().RGBToColor(r, g, b);
}

int GraphicsManager::getImageSlot(const Common::String &filename) {
	// Let's find a match, an open slot, or the oldest image slot
	uint32 oldestAge = 0xffffffff;
	int slot = 0;

	for (int i = 0; i < kImageCacheSize; i++) {
		if (_cache[i].filename.equalsIgnoreCase(filename)) {
			//warning("Found image %s at slot %d", filename.c_str(), i);
			_cache[i].lastUsed = _vm->_system->getMillis();
			return i;
		}

		if (!_cache[i].surface) {
			//warning("Putting image %s in empty slot %d", filename.c_str(), i);
			_cache[i].filename = filename;
			_cache[i].lastUsed = _vm->_system->getMillis();
			return i;
		}

		if (_cache[i].lastUsed < oldestAge) {
			oldestAge = _cache[i].lastUsed;
			slot = i;
		}
	}

	// Let's make sure that's cleaned out
	//warning("Replacing old image %s with %s in slot %d", _cache[slot].filename.c_str(), filename.c_str(), slot);
	_cache[slot].filename = filename;
	_cache[slot].surface->free();
	delete _cache[slot].surface;
	_cache[slot].surface = 0;
	_cache[slot].lastUsed = _vm->_system->getMillis();
	return slot;
}
	
} // End of namespace Pegasus
