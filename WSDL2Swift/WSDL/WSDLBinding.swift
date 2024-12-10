//
//  WSDLBinding.swift
//  WSDL2Swift
//
//  Created by Milko Daskalov on 19.11.24.
//
import Foundation

struct WSDLBinding {
    let name: String
    // omit check for: <soap:binding transport="http://schemas.xmlsoap.org/soap/http" style="document" />
    // omit check for <operations> other than WSDLOperation, without any informative parts
    init?(_ element: XMLElement?) {
        guard
            let name = element?.attribute(forName: "name")?.stringValue
        else {
            error(on: element, message: "Cannot initialize WSDBinding")
            return nil
        }
        self.name = name
    }
}
