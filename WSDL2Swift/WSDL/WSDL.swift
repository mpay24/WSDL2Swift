//
//  WSDL.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDL {
    let publicMemberwiseInit: Bool
    let targetNamespace: String
    let simpleTypes: [XSDSimpleType]
    let complexTypes: [XSDComplexType]
    let messages: [WSDLMessage]
    let portType: WSDLPortType
    let binding: WSDLBinding
    let service: WSDLService
    
    init?(_ element: XMLElement?, _ publicMemberwiseInit: Bool = false) {
        guard
            let tns = element?.attribute(forName: "targetNamespace")?.stringValue,
            let types = element?.elements(forName: "wsdl:types").first,
            let schema = types.elements(forName: "xsd:schema").first,
            let portType = WSDLPortType(element?.elements(forName: "wsdl:portType").first),
            let binding = WSDLBinding(element?.elements(forName: "wsdl:binding").first),
            let service = WSDLService(element?.elements(forName: "wsdl:service").first)
        else { return nil }
        self.publicMemberwiseInit = publicMemberwiseInit
        self.targetNamespace = tns
        do {
            self.simpleTypes = try schema.nodes(forXPath: "xsd:element[xsd:simpleType]|xsd:simpleType").compactMap { XSDSimpleType($0 as? XMLElement) }
            self.complexTypes = try schema.nodes(forXPath: "xsd:element[xsd:complexType]|xsd:complexType").compactMap { XSDComplexType($0 as? XMLElement) }
            self.messages = element?.elements(forName: "wsdl:message").compactMap { WSDLMessage($0) } ?? []
            self.portType = portType
            self.binding = binding
            self.service = service
        } catch {
            print("Error parsing WSDL: \(error)")
            return nil
        }
    }
    
    func isProtocol(_ typeName: String) -> Bool {
        complexTypes.contains(where: { $0.base == typeName })
    }
    
    func protocolExtensions(_ typeName: String) -> [String] {
        complexTypes.filter { $0.base == typeName }.map { $0.name }
    }
    
    var dictionary: [String: Any] {
        let protocolTypeNames = complexTypes.filter { isProtocol($0.name) }.map { $0.name }
        // Update type hierarchy
        let complexTypes: [[String:Any]] = self.complexTypes.map {
            var dictionary = $0.dictionary
            let baseTypeName = $0.base
            let baseType = self.complexTypes.first(where: { $0.name == baseTypeName })
            let isProtocol = protocolTypeNames.contains($0.name)
            let hasProtocolElements = $0.elements.first(where: { protocolTypeNames.contains($0.type) }) != nil
            let hasProtocolBaseElements = baseType?.elements.first(where: { protocolTypeNames.contains($0.type) }) != nil
            dictionary["isProtocol"] = isProtocol
            dictionary["elements"] = $0.elements.map {
                var dictionary = $0.dictionary
                dictionary["protocol"] = protocolTypeNames.contains($0.type) //TODO: Encode optional protocols
                return dictionary
            }
            dictionary["baseElements"] = baseType?.elements.map { $0.dictionary }
            dictionary["hasProtocolElements"] = hasProtocolElements || hasProtocolBaseElements
            return dictionary
        }
        
        return [
            "targetNamespace": targetNamespace,
            "name": service.name,
            "documentation": service.documentation ?? "",
            "location": service.port.location,
            "path": service.port.path,
            "operations": portType.operations.map { $0.dictionary },
            "simpleTypes": simpleTypes.map { $0.dictionary },
            "complexTypes": complexTypes,
            "publicMemberwiseInit": publicMemberwiseInit
        ]
    }
}
