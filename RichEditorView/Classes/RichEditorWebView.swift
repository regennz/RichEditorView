//
//  RichEditorWebView.swift
//  RichEditorView
//
//  Created by C. Bess on 9/18/19.
//

import Foundation
import WebKit

// these methods were added to swizzle the keyboard methods of the webview
typealias OldClosureType = @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Any?) -> Void
typealias NewClosureType = @convention(c) (Any, Selector, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void

public class RichEditorWebView: WKWebView {

    public var accessoryView: UIView?
    private var _keyboardDisplayRequiresUseraction = true

    public override var inputAccessoryView: UIView? {
        return accessoryView
    }

    public var keyboardDisplayRequiresUserAction: Bool? {
        get {
            return _keyboardDisplayRequiresUseraction
        }
        set {
            _keyboardDisplayRequiresUseraction = newValue ?? true
            setKeyboardRequiresUserInteraction(_keyboardDisplayRequiresUseraction)
        }
    }

    private func setKeyboardRequiresUserInteraction(_ value: Bool) {
        guard let WKContentViewClass: AnyClass = NSClassFromString("WKContentView") else {
            return print("Cannot find WKContentView class")
        }

        let oldSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:")
        let newSelector: Selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:")

        if let method = class_getInstanceMethod(WKContentViewClass, oldSelector) {
            let originalImp: IMP = method_getImplementation(method)
            let original: OldClosureType = unsafeBitCast(originalImp, to: OldClosureType.self)
            let block: @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3) in
                original(me, oldSelector, arg0, !value, arg2, arg3)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
        if let method = class_getInstanceMethod(WKContentViewClass, newSelector) {
            let originalImp: IMP = method_getImplementation(method)
            let original: NewClosureType = unsafeBitCast(originalImp, to: NewClosureType.self)
            let block: @convention(block) (Any, UnsafeRawPointer, Bool, Bool, Bool, Any?) -> Void = { (me, arg0, arg1, arg2, arg3, arg4) in
                original(me, newSelector, arg0, !value, arg2, arg3, arg4)
            }
            let imp: IMP = imp_implementationWithBlock(block)
            method_setImplementation(method, imp)
        }
    }
}
