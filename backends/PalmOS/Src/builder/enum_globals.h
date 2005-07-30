#ifndef __ENUM_GLOBALS_H__
#define __ENUM_GLOBALS_H__

// Common
enum {
	GBVARS_GUIFONT_INDEX = 0,
	GBVARS_FONTBITS_INDEX
};

// Scumm
enum {
	GBVARS_DIGSTATEMUSICMAP_INDEX = 0,
	GBVARS_DIGSTATEMUSICTABLE_INDEX,
	GBVARS_DIGSEQMUSICTABLE_INDEX,
	GBVARS_COMISTATEMUSICTABLE_INDEX,
	GBVARS_COMISEQMUSICTABLE_INDEX,
	GBVARS_FTSTATEMUSICTABLE_INDEX,
	GBVARS_FTSEQMUSICTABLE_INDEX,
	GBVARS_FTSEQNAMES_INDEX,
	GBVARS_DEFAULTSCALETABLE_INDEX,
	GBVARS_OLDSCALETABLE_INDEX,
	GBVARS_IMCTABLE_INDEX,
	GBVARS_CODEC47TABLE_INDEX,
	GBVARS_TRANSITIONEFFECTS_INDEX,
	GBVARS_STRINGMAPTABLEV7_INDEX,
	GBVARS_STRINGMAPTABLEV6_INDEX,
	GBVARS_STRINGMAPTABLEV5_INDEX,
	GBVARS_GERMANCHARSETDATAV2_INDEX,
	GBVARS_FRENCHCHARSETDATAV2_INDEX,
	GBVARS_ENGLISHCHARSETDATAV2_INDEX,
	GBVARS_ITALIANCHARSETDATAV2_INDEX,
	GBVARS_SPANISHCHARSETDATAV2_INDEX,
	GBVARS_COSTSCALETABLE_INDEX,
	GBVARS_NOTELENGTHS_INDEX,
	GBVARS_HULLOFFSETS_INDEX,
	GBVARS_HULLS_INDEX,
	GBVARS_FREQMODLENGTHS_INDEX,
	GBVARS_FREQMODOFFSETS_INDEX,
	GBVARS_FREQMODTABLE_INDEX,
	GBVARS_SPKFREQTABLE_INDEX,
	GBVARS_PCJRFREQTABLE_INDEX
};
// Simon
enum {
	GBVARS_SIMON1SETTINGS_INDEX = 0,
	GBVARS_SIMON1ACORNSETTINGS_INDEX,
	GBVARS_SIMON1AMIGASETTINGS_INDEX,
	GBVARS_SIMON1DEMOSETTINGS_INDEX,
	GBVARS_SIMON2WINSETTINGS_INDEX,
	GBVARS_SIMON2DOSSETTINGS_INDEX,
	GBVARS_RUSSIANVIDEOFONT_INDEX,
	GBVARS_FRENCHVIDEOFONT_INDEX,
	GBVARS_GERMANVIDEOFONT_INDEX,
	GBVARS_HEBREWVIDEOFONT_INDEX,
	GBVARS_ITALIANVIDEOFONT_INDEX,
	GBVARS_SPANISHVIDEOFONT_INDEX,
	GBVARS_VIDEOFONT_INDEX,
	GBVARS_SIMON1CURSOR_INDEX
//	GBVARS_SIMON2CURSORS_INDEX
};
// Queen
enum {
	GBVARS_SPEECHPARAMETERS_INDEX = 0,
	GBVARS_RESOURCETABLEPM10_INDEX,
	GBVARS_GRAPHICSCARDATA_INDEX,
	GBVARS_GRAPHICSFIGHT1DATA_INDEX,
	GBVARS_GRAPHICSFIGHT2DATA_INDEX,
	GBVARS_GRAPHICSFIGHT3DATA_INDEX,
	GBVARS_DISPLAYFONTREGULAR_INDEX,
	GBVARS_DISPLAYFONTHEBREW_INDEX,
	GBVARS_DISPLAYPALJOECLOTHES_INDEX,
	GBVARS_DISPLAYPALJOEDRESS_INDEX,
	GBVARS_MUSICDATASONGDEMO_INDEX,
	GBVARS_MUSICDATASONG_INDEX,
	GBVARS_MUSICDATATUNEDEMO_INDEX,
	GBVARS_MUSICDATATUNE_INDEX,
	GBVARS_MUSICDATASFXNAME_INDEX,
	GBVARS_MUSICDATAJUNGLELIST_INDEX
};
// Sky
enum {
	GBVARS_HUFFTREE_00109_INDEX = 0,
	GBVARS_HUFFTREE_00267_INDEX,
	GBVARS_HUFFTREE_00288_INDEX,
	GBVARS_HUFFTREE_00303_INDEX,
	GBVARS_HUFFTREE_00331_INDEX,
	GBVARS_HUFFTREE_00348_INDEX,
	GBVARS_HUFFTREE_00365_INDEX,
	GBVARS_HUFFTREE_00368_INDEX,
	GBVARS_HUFFTREE_00372_INDEX,
};
// Sword1
enum {
	GBVARS_FXLIST_INDEX = 0
};

enum {
	GBVARS_COMMON = 0,
	GBVARS_ENGINE = 1,
	GBVARS_SCUMM = GBVARS_ENGINE,
	GBVARS_SIMON = GBVARS_ENGINE,
	GBVARS_SKY = GBVARS_ENGINE,
	GBVARS_SWORD1 = GBVARS_ENGINE,
//	GBVARS_SWORD2 = GBVARS_ENGINE,
	GBVARS_QUEEN = GBVARS_ENGINE,
	GBVARS_SAGA = GBVARS_ENGINE,

	GBVARS_COUNT
};

#endif
