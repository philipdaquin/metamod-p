// vi: set ts=4 sw=4 :
// vi: set tw=75 :

// osdep_wasm.cpp - WASM-specific operating system dependencies
// This provides implementations for dynamic linking in Emscripten WASM environment

/*
 * Copyright (c) 2001-2006 Will Day <willday@hpgx.net>
 *
 *    This file is part of Metamod.
 *
 *    Metamod is free software; you can redistribute it and/or modify it
 *    under the terms of the GNU General Public License as published by the
 *    Free Software Foundation; either version 2 of the License, or (at
 *    your option) any later version.
 *
 *    Metamod is distributed in the hope that it will be useful, but
 *    WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Metamod; if not, write to the Free Software Foundation,
 *    Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <string.h>
#include <emscripten.h>

#include "osdep.h"
#include "mreg.h"
#include "log_meta.h"
#include "types_meta.h"
#include "support_meta.h"

mBOOL dlclose_handle_invalid;

// WASM doesn't use traditional dlopen/dlsym - in Emscripten SIDE_MODULE,
// symbols are resolved at link time. However, for runtime loading of plugins,
// we need to provide stubs or use Emscripten's module loading system.

// Stub implementations for WASM - actual dynamic loading is handled
// differently in the Emscripten environment
inline DLHANDLE DLLINTERNAL DLOPEN(const char *filename) {
    // In WASM SIDE_MODULE, we return the module itself
    // The actual loading is handled by the main Xash3D module
    return (void*)1;  // Non-null stub
}

inline DLFUNC DLLINTERNAL DLSYM(DLHANDLE handle, const char *string) {
    // In WASM, symbols from the main module are imported
    // This is handled via Emscripten's export mechanism
    return NULL;  // Return NULL - actual symbols come from imports
}

inline int DLLINTERNAL DLCLOSE(DLHANDLE handle) {
    if(!handle) {
        dlclose_handle_invalid = mTRUE;
        return(1);
    }
    dlclose_handle_invalid = mFALSE;
    return(0);  // Can't actually unload in WASM
}

inline const char * DLLINTERNAL DLERROR(void) {
    if(dlclose_handle_invalid)
        return("Invalid handle.");
    return("WASM module loading error");
}

const char * DLLINTERNAL DLFNAME(void *memptr) {
    return("wasm_module");
}

mBOOL DLLINTERNAL IS_VALID_PTR(void *memptr) {
    return (memptr != NULL) ? mTRUE : mFALSE;
}
