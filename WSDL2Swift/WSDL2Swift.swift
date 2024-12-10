import Foundation
import Stencil
import ArgumentParser

@main
struct WSDL2Swift: ParsableCommand {
    @Flag(help: "synthesize public memberwise init instead of default internal one")
    var publicMemberwiseInit = false
    @Option(help: "(overwrite) output swift file path for generated swift")
    var out: String = "./WSDL.swift"
    @Argument(help: "WSDL xmls and XSD xmls, ordered as: ws1.xml ws2.xml xsd-for-ws2.xml ws3.xml xsd-for-ws3-1.xml xsd-for-ws3-2.xml ...")
    var files: [String]
    
    mutating func run() throws {
        var wsdls: [WSDL] = []

        // each file can be either WSDL or XSD file
        for file in files {
            var definitions : XMLElement?
            do {
                let fileURL = URL(fileURLWithPath: (file as NSString).expandingTildeInPath)
                let data = try Data(contentsOf: fileURL)
                definitions = try XMLDocument(data: data).rootElement()
            } catch {
                print("Error reading WSDL file: \(file): \(error)")
                return
            }
            guard definitions?.localName == "definitions" else {
                print("error: Invalid WSDL - 'definitions' element missing in \(file)")
                return
            }
            
            let wsdlNs = XMLElement.namespace(withName: "wsdl", stringValue: "http://schemas.xmlsoap.org/wsdl/")
            let soapNs = XMLElement.namespace(withName: "soap", stringValue: "http://schemas.xmlsoap.org/wsdl/soap/")
            let xsdNs = XMLElement.namespace(withName: "xsd", stringValue: "http://www.w3.org/2001/XMLSchema")
            let xsiNs = XMLElement.namespace(withName: "xsi", stringValue: "http://www.w3.org/2001/XMLSchema-instance")

            definitions?.namespaces = [wsdlNs, soapNs, xsdNs, xsiNs].compactMap { $0 as? XMLNode }
            
            if let wsdl = WSDL(definitions) {
                wsdls.append(wsdl)
            }
        }

        if wsdls.isEmpty {
            print("error: no WSDLs parsed in: \(files)")
            return
        }
        
        wsdls.forEach { wsdl in
            let fileURL = URL(fileURLWithPath: (out as NSString).expandingTildeInPath)
            let file = fileURL.deletingLastPathComponent().appendingPathComponent("WSDL+\(wsdl.service.name).swift")
            do {
                let environment = Environment(loader: FileSystemLoader(paths: ["Stencils"]))
                let template = try environment.loadTemplate(name: "WSDLService.stencil")
                let swift = try template.render(wsdl.dictionary)
                try swift.write(to: file, atomically: true, encoding: .utf8)
            } catch {
                print("error writing Swift file: \(error)")
            }
        }
    }
}
