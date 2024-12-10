//
//  WSDLMessage.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLMessage {
    let name: String
    let element: String?
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let part = element?.elements(forName: "wsdl:part").first
        else {
            error(on: element, message: "Cannot initialize WSDLMessage")
            return nil
        }
        self.name = name
        self.element = part.attribute(forName: "element")?.stringValue
    }
}
