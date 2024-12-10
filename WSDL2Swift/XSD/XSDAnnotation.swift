//
//  XSDAnnotation.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct XSDAnnotation {
    let documentation: String
    
    init?(_ element: XMLElement?) {
        guard let documentation = element?.elements(forName: "xsd:documentation").first?.stringValue else {
            return nil
        }
        self.documentation = documentation.replacingOccurrences(of: "\n", with: "")
    }
    
    var dictionary: [String: Any] {[
        "documentation": documentation
    ]}
}
