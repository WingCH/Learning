//
//  ViewController.swift
//  study-accessibility
//
//  Created by Wing on 1/4/2023.
//

import Cocoa

class ViewController: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 請求輔助功能權限
        requestAccessibilityPermission()
    }
    
    func requestAccessibilityPermission() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        
        if accessEnabled {
            print("Accessibility Permission Granted")
            
            // 獲取當前窗口的文本
            let windowText = getWindowText()
            print("Window text: \(windowText)")
        } else {
            print("Accessibility Permission Denied")
        }
    }
    
    func getWindowText() -> String {
        // 創建一個系統範圍內的 UI 元素
        let systemWideElement = AXUIElementCreateSystemWide()
        // 定義一個用於存儲當前聚焦應用程式的變量
        var focusedApp: AnyObject?
        // 從系統範圍內的 UI 元素獲取當前聚焦應用程式的屬性值，並將其存儲在 focusedApp 變量中
        AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedApplicationAttribute as CFString, &focusedApp)
        
        // 檢查 focusedApp 變量是否包含有效的 AXUIElement 對象，否則返回空字符串
        guard let app = focusedApp as! AXUIElement? else { return "" }
        
        // 定義一個用於存儲當前聚焦窗口的變量
        var focusedWindow: AnyObject?
        // 從當前聚焦應用程式的 UI 元素獲取當前聚焦窗口的屬性值，並將其存儲在 focusedWindow 變量中
        AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        // 檢查 focusedWindow 變量是否包含有效的 AXUIElement 對象，否則返回空字符串
        guard let window = focusedWindow as! AXUIElement? else { return "" }
        
        // 調用 getAccessibilityText 函數，傳入當前聚焦窗口的 UI 元素，以獲取窗口中的文本信息
        return getAccessibilityText(from: window)
    }

    
    func getAccessibilityText(from element: AXUIElement) -> String {
        // 定義一個用於存儲提取到的文本的字符串變量
        var text = ""
        
        // 定義一個用於存儲元素角色的變量
        var role: AnyObject?
        // 從指定的 AXUIElement 獲取角色屬性值，並將其存儲在 role 變量中
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        
        // 如果元素角色是靜態文本（kAXStaticTextRole），則獲取其值屬性（即文本）
        if let roleValue = role as? String, roleValue == kAXStaticTextRole as String {
            var value: AnyObject?
            // 從指定的 AXUIElement 獲取值屬性，並將其存儲在 value 變量中
            AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &value)
            // 如果值屬性是字符串，則將其添加到 text 變量中
            if let valueText = value as? String {
                text += valueText
            }
        } else {
            // 定義一個用於存儲子元素的變量
            var children: AnyObject?
            // 從指定的 AXUIElement 獲取子元素屬性值，並將其存儲在 children 變量中
            AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children)
            // 如果子元素存在，則遞歸地提取每個子元素的文本信息並添加到 text 變量中
            if let childrenElements = children as? [AXUIElement] {
                for childElement in childrenElements {
                    text += getAccessibilityText(from: childElement)
                }
            }
        }
        
        // 返回提取到的文本信息
        return text
    }

}

