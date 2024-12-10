//
//  WSDLServicePort.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLServicePort {
    let name: String
    let binding: String
    let location: String // <soap:address location="*" />
    let path: String
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let binding = element?.attribute(forName: "binding")?.stringValue,
            let address = element?.elements(forName: "soap:address").first,
            let location = address.attribute(forName: "location")?.stringValue
        else {
            error(on: element, message: "Cannot initialize WSDLServicePort")
            return nil
        }
        self.name = name
        self.binding = binding
        self.location = location
        let url = URL(string: location)
        let path = url?.path ?? url?.lastPathComponent ?? location
        self.path = String(path.dropFirst(path.first == "/" ? 1 : 0))
    }
}
