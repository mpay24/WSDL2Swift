//
//  XSDComplexType.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct XSDComplexType {
    let name: String
    let annotation: XSDAnnotation?
    let base: String?
    let elements: [XSDElement]
    
    init?(_ element: XMLElement?) {
        guard let name = element?.attribute(forName: "name")?.stringValue else {
            error(on: element, message: "Cannot initialize XSDComplexType")
            return nil
        }
        self.name = name
        
        let complexTypeElement = element?.localName == "element" ? element?.elements(forName: "xsd:complexType").first : element
        
        self.annotation = XSDAnnotation(complexTypeElement?.elements(forName: "xsd:annotation").first)
        if let sequence = complexTypeElement?.elements(forName: "xsd:sequence").first {
            base = nil
            self.elements = sequence.elements(forName: "xsd:element").compactMap { XSDElement($0) }
        } else if let complexContent = complexTypeElement?.elements(forName: "xsd:complexContent").first,
            let ext = complexContent.elements(forName: "xsd:extension").first,
            let sequence = ext.elements(forName: "xsd:sequence").first {
            guard let baseType = baseTypeFrom(element: ext) else {
                error(on: ext, message: "Can't determine base type")
                return nil
            }
            base = baseType
            self.elements = sequence.elements(forName: "xsd:element").compactMap { XSDElement($0) }
        } else {
            error(on: complexTypeElement, message: "XSDComplexType \(name): Cannot initialize")
            return nil
        }
    }
    
    var dictionary: [String: Any] {[
        "name": swiftSafeName(name),
        "annotation": annotation?.dictionary ?? [:],
        "base": base ?? "",
        "elements": elements.map { $0.dictionary },
    ]}
}
