struct WSDLServicePort {
    var name: String
    var binding: String
    var location: String // <soap:address location="*" />
    
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue,
            let binding = element?.attribute(forName: "binding")?.stringValue,
            let address = element?.elements(forLocalName: "address", uri: SOAP_NS).first,
            let location = address.attribute(forName: "location")?.stringValue
        else {
            error(on: element, message: "Cannot initialize WSDLServicePort")
            return nil
        }
        self.name = name
        self.binding = binding
        self.location = location
    }
}