import objc as _objc
import MultitouchStreaming

_frameworkPath = "/AppleInternal/Library/Frameworks/LunaSupport.framework"

__bundle__ = _objc.initFrameworkWrapper("LunaSupport",
                                        frameworkIdentifier="com.apple.LunaSupport",
                                        frameworkPath=_objc.pathForFramework(_frameworkPath),
                                        globals=globals())

# Register selectors with blocks

_blockWith1Arg = {
    "arguments": {
        2 + 0: {"type_modifier": _objc._C_OUT},
        2 + 1: {
            "type": "^@", "callable": {
                "arguments": {
                    0: {"type": "^v"},
                    1: {"type": "@"}
            }
        }
}
}
}

_classes = [
            b"LunaDevice",
            ]

_selectors = [
              b"setSampleAction:action:",
              ]

_argsOut = {
    0: [
        ],
        1: [
            b"getReport:error:",
            b"startWithRunLoop:error:",
            ],
        2: [
            b"setReport:data:error:",
            ]
}

for claxx in _classes:
    for selector in _selectors:
        _objc.registerMetaDataForSelector(claxx, selector, _blockWith1Arg)

    for numArgs in _argsOut.keys():
        for selector in _argsOut[numArgs]:
            _objc.registerMetaDataForSelector(claxx, selector, {
                                              "arguments": {
                                              2 + numArgs: {"type_modifier": _objc._C_OUT},
                                              }
                                              })

