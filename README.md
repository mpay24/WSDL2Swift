WSDL2Swift
==========

Swift alternative to WSDL2ObjC making a SOAP request & parsing its response as defined in WSDL using modern Swift.

## Input & Output

Input

* WSDL 1.1 xmls
* XSD xmls

Output

* a Swift file which works as SOAP client
	* Swift 6 (Xcode 16.1)
	* URLSession asynchronous connection
 	* Custom charset encoding
  	* Basic Authentication
	* [XMLCoder](https://github.com/CoreOffice/XMLCoder.git) for generating and parsing xml using Codable protocol

## Usage

### Build

You can build and debug with WSDL2Swift scheme of the xcodeproj. Archive build is not supported yet.

### Generate

Generate WSDL.swift from WSDL and XSD xmls:

```sh
./build/Build/Products/Release/WSDL2Swift --out path/to/WSDL.swift path/to/service.wsdl.xml path/to/service.xsd.xml
```

The order of input files is important - referenced XSDs should be placed immediately after referencing WSDL.

### Use In App

Add generated swift file to your project.
(service name and requeest types are extracted from the source WSDL)

Generated code from the temperature converter w3schools example:

```swift
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
    
    public func FahrenheitToCelsius(_ req: FahrenheitToCelsius) async throws -> FahrenheitToCelsiusResponse {
        return try await operation(req)
    }
    
    public func CelsiusToFahrenheit(_ req: CelsiusToFahrenheit) async throws -> CelsiusToFahrenheitResponse {
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
```

Using the generated client (the package WSDLService introduces runtime dependencies):

```swift
import WSDLService

let service = TempConvert()
let request = TempConvert.CelsiusToFahrenheit(Celsius: "23.4")
let response = await service.CelsiusToFahrenheit(request)
print("\(request) = \(response)")
```

### Customizations

Initialize using custom domain:

```swift
let service = TempConvert("https://www.w3schools.com")
```

Modify the endpoint directly (use `var` to make the service mutable):

```swift
var service = TempConvert()
service.endpoint = "https://custom.com/service"
```

Specify the charset used in the SOAP request (`.unspecified` by default):

```swift
service.characterSet = .utf8
```

Add basic authentication:

```swift
service.authentication = .basic(username: "...", password: "...")
```

Intercept the SOAP communcation:
```swift
service.soapRequest = { print("req:\n\($0)") }
service.soapResponse = { print("res:\n\($0)") }
```
