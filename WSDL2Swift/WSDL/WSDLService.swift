//
//  WSDLService.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLService {
    let name: String
    let port: WSDLServicePort
    let documentation: String?
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let ports = element?.elements(forName: "wsdl:port"),
            let port = WSDLServicePort(ports.filter({ $0.elements(forName: "soap:address") != [] }).first)
        else {
            error(on: element, message: "Cannot initialize WSDLService")
            return nil
        }
        self.name = name
        self.port = port
        self.documentation = try? element?.nodes(forXPath: "documentation").first?.stringValue
    }
}
