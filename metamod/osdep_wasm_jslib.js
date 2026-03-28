// osdep_wasm_jslib.js
// JavaScript library for Emscripten WASM build
// Provides dynamic linking stubs for metamod

mergeInto(LibraryManager.library, {
    // Stub for dlopen - in WASM, modules are loaded differently
    emscripten_run_script: function() {},

    // Provide a minimal module loading interface
    $DLOPEN: {
        loaded: {},
    },

    // Override dlopen to work with our module loading
    dlopen: function(filename, flags) {
        // In WASM SIDE_MODULE, we return a handle of 1
        // The actual symbol resolution happens at link time
        return 1;
    },

    // dlsym returns null for unknown symbols in our WASM build
    dlsym: function(handle, symbol) {
        return null;
    },

    dlclose: function(handle) {
        return 0;
    },

    dlerror: function() {
        return "WASM dynamic linking not fully supported - using static linking";
    },

    // Provide main module exports that metamod expects
    _GiveFnptrsToDll: function(fnptr, pplate, temp) {
        // This is called by the engine to give function pointers to metamod
        // In WASM, this is handled via imports/exports
    },

    // Provide memcpy etc if not available
    memcpy: function(dest, src, num) {
        for (var i = 0; i < num; i++) {
            HEAP8[dest + i] = HEAP8[src + i];
        }
        return dest;
    },

    memset: function(dest, value, num) {
        for (var i = 0; i < num; i++) {
            HEAP8[dest + i] = value;
        }
        return dest;
    },

    memmove: function(dest, src, num) {
        if (dest === src) return dest;
        if (src + num <= dest) {
            for (var i = 0; i < num; i++) {
                HEAP8[dest + i] = HEAP8[src + i];
            }
        } else {
            for (var i = num - 1; i >= 0; i--) {
                HEAP8[dest + i] = HEAP8[src + i];
            }
        }
        return dest;
    },
});
