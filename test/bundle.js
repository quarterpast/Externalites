!function (definition) {
    return typeof exports === 'object' ? module.exports = definition(require('underscore')) : typeof define === 'function' && define.amd ? define(['underscore'], definition) : window.Test = definition(window._);
}(function (_) {
    return function e(t, n, r) {
        function s(o, u) {
            if (!n[o]) {
                if (!t[o]) {
                    var a = typeof require == 'function' && require;
                    if (!u && a)
                        return a(o, !0);
                    if (i)
                        return i(o, !0);
                    throw new Error('Cannot find module \'' + o + '\'');
                }
                var f = n[o] = { exports: {} };
                t[o][0].call(f.exports, function (e) {
                    var n = t[o][1][e];
                    return s(n ? n : e);
                }, f, f.exports, e, t, n, r);
            }
            return n[o].exports;
        }
        var i = typeof require == 'function' && require;
        for (var o = 0; o < r.length; o++)
            s(r[o]);
        return s;
    }({
        1: [
            function (_dereq_, module, exports) {
                module.exports = 'b';
            },
            {}
        ],
        2: [
            function (_dereq_, module, exports) {
                var b = _dereq_('./b');
            },
            { './b': 1 }
        ]
    }, {}, [2])(2);
})