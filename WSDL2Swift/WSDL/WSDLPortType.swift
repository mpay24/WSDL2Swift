//
//  WSDLPortType.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLPortType {
    let name: String
    let operations: [WSDLOperation]
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let operations = element?.elements(forName: "wsdl:operation")
        else {
            error(on: element, message: "Cannot initialize WSDLPortType")
            return nil
        }
        self.name = name
        self.operations = operations.compactMap { WSDLOperation($0) }
    }
}
