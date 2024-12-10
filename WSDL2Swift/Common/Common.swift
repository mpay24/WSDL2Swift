//
//  Common.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//

import Foundation

fileprivate let TYPE_MAP: [String: Any.Type] = [
    "string": String.self,
    "boolean": Bool.self,
    "int": Int32.self,
    "unsignedInt": UInt32.self,
    "long": Int64.self,
    "unsignedLong": UInt64.self,
    "date": Date.self,
    "dateTime": Date.self,
    "base64Binary": Data.self,
    "anyURI": URL.self,
]

func swiftSafeName(_ name: String) -> String {
    let swiftKeywords = [ "operator", "return" ]
    let safeName = name.replacingOccurrences(of: "-", with: "_")
    return swiftKeywords.contains(safeName) ? safeName + "_" : safeName
}

func findTargetNamespace(on element: XMLElement) -> String? {
    if let targetNamespace = element.attribute(forName: "targetNamespace")?.stringValue {
        return targetNamespace
    }
    guard let parent = element.parent as? XMLElement else { return nil }
    return findTargetNamespace(on: parent)
}

func stripTargetNamespace(from type: String, on onElement: XMLElement?) -> String {
    if let element = onElement,
        let targetNamespace = findTargetNamespace(on: element),
        let prefix = element.resolvePrefix(forNamespaceURI: targetNamespace)  {
        return type.replacingOccurrences(of: "\(prefix):", with: "")
    }
    return type
}

func swiftType(of type: String, from element: XMLElement?) -> String?{
    let typeLocalName = XMLNode.localName(forName: type)
    guard let swiftType = TYPE_MAP[typeLocalName] else {
        return swiftSafeName(stripTargetNamespace(from: type, on: element))
    }
    return String(describing: swiftType)
}

func baseTypeFrom(element: XMLElement?) -> String? {
    guard let type = element?.attribute(forName: "base")?.stringValue else { return nil }
    return swiftType(of: type, from: element)
}

func error(on element: XMLElement?, message: String) {
    let elementXML = element?.xmlString(options: .nodePrettyPrint)
    let elementMessage = elementXML != nil ? " while parsing:\n\(elementXML!)" : ""
    NSLog("%@", "\(message)\(elementMessage)")
}
