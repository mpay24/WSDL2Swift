import Foundation
import XMLCoder

public struct TempConvert: WSDLService {
    public var endpoint = "http://www.w3schools.com/xml/tempconvert.asmx"
    public var targetNamespace = "https://www.w3schools.com/xml/"
    public var authentication: Authentication = .none
    public var characterSet: CharacterSet = .unspecified
    public var soapRequest: ((_ request: String) -> Void)?
    public var soapResponse: ((_ response: String) -> Void)?
    public init(_ domain: String? = nil) {
        if let domain {
            self.endpoint = "\(domain)/xml/tempconvert.asmx"
        }
    }
    
    public func FahrenheitToCelsius(_ req: FahrenheitToCelsiusSoapIn) async throws -> FahrenheitToCelsiusSoapOut {
        return try await operation(req)
    }
    
    public func CelsiusToFahrenheit(_ req: CelsiusToFahrenheitSoapIn) async throws -> CelsiusToFahrenheitSoapOut {
        return try await operation(req)
    }
    
    public struct FahrenheitToCelsius: Codable {
        public var Fahrenheit: String?
    }
    
    public struct FahrenheitToCelsiusResponse: Codable {
        public var FahrenheitToCelsiusResult: String?
    }
    
    public struct CelsiusToFahrenheit: Codable {
        public var Celsius: String?
    }
    
    public struct CelsiusToFahrenheitResponse: Codable {
        public var CelsiusToFahrenheitResult: String?
    }
}
