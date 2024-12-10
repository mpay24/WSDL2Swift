//
//  XSDSimpleType.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct XSDSimpleType {
    let name: String
    let annotation: XSDAnnotation?
    let base: String?
    let enumeration: [String]?
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let restriction = element?.elements(forName: "xsd:restriction").first
        else {
            error(on: element, message: "Cannot initialize XSDSimpleType")
            return nil
        }
        self.name = name
        
        let simpleTypeElement = element?.localName == "element" ? element?.elements(forName: "xsd:simpleType").first : element
        
        self.annotation = XSDAnnotation(simpleTypeElement?.elements(forName: "xsd:annotation").first)
        self.base = baseTypeFrom(element: restriction) ?? "String"
        self.enumeration = restriction.elements(forName: "xsd:enumeration").map({
            swiftSafeName($0.attribute(forName: "value")?.stringValue ?? "none")
        })
        guard self.enumeration?.count ?? 0 > 0 else {
            error(on: simpleTypeElement, message: "XSDSimpleType \(name): Cannot initialize enumeration values")
            return nil
        }
    }
    
    var dictionary: [String: Any] {[
        "name": swiftSafeName(name),
        "annotation": annotation?.dictionary ?? [:],
        "base": base ?? "",
        "enumeration": enumeration ?? [:]
    ]}
}
