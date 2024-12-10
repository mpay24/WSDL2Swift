//
//  XSDElement.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct XSDElement {
    let name: String
    let type: String
    let optional: Bool
    let unbounded: Bool
    
    public init?(_ element: XMLElement?) {
        guard let name = element?.attribute(forName: "name")?.stringValue else {
            error(on: element, message: "Cannot initialize XSDElement")
            return nil
        }
        self.name = name
        var type: String
        if let basicType = element?.attribute(forName: "type")?.stringValue {
            type = swiftType(of: basicType, from: element) ?? swiftSafeName(basicType)
        } else if let complexType = XSDComplexType(element?.elements(forName: "xsd:complexType").first) {
            type = complexType.name
        } else {
            error(on: element, message: "XSDElement \(name): Cannot initialize element type")
            return nil
        }
        let minOccurs = element?.attribute(forName: "minOccurs")?.stringValue.flatMap { UInt($0) } ?? 1 // XSD default = 1
        let maxOccurs = element?.attribute(forName: "maxOccurs")?.stringValue ?? "1"  // XSD default = 1
                
        self.type = maxOccurs == "1" ? type : "[\(type)]"
        self.optional = minOccurs == 0
        self.unbounded = maxOccurs == "unbounded"
    }
    
    var dictionary: [String: Any] {[
        "name": name,
        "swiftName": swiftSafeName(name),
        "type": type,
        "optional": optional,
        "unbounded": unbounded
    ]}
}
