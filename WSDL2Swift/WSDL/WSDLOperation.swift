//
//  WSDLOperation.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLOperation {
    let name: String
    let documentation: String
    let inputMessage: String
    let outputMessage: String
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let input = element?.elements(forName: "wsdl:input").first,
            let inputMessage = input.attribute(forName: "message")?.stringValue,
            let output = element?.elements(forName: "wsdl:output").first,
            let outputMessage = output.attribute(forName: "message")?.stringValue
        else {
            error(on: element, message: "Cannot initialize WSDLOperation")
            return nil
        }
        self.name = name
        self.documentation = element?.elements(forName: "wsdl:documentation").first?.stringValue ?? ""
        self.inputMessage = inputMessage
        self.outputMessage = outputMessage
    }
    
    var dictionary: [String: Any] {[
        "name": swiftSafeName(name),
        "documentation": documentation,
        "inParam": XMLNode.localName(forName: inputMessage),
        "outParam": XMLNode.localName(forName: outputMessage),
    ]}
}
