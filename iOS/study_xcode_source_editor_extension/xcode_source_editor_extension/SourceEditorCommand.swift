//
//  SourceEditorCommand.swift
//  xcode_source_editor_extension
//
//  Created by Wing on 16/4/2023.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        // get text use invocation
        let text = invocation.buffer.completeBuffer
        
        completionHandler(nil)
    }
    
}
