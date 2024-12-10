import Foundation
import XMLCoder

public protocol WSDLService {
    var endpoint: String { get set }
    var targetNamespace: String { get }
    var authentication: Authentication { get set }
    var characterSet: CharacterSet { get set }
    var soapRequest: ((_ request: String) -> Void)? { get set }
    var soapResponse: ((_ response: String) -> Void)? { get set }
    init(_ domain: String?)
}

public extension WSDLService {
    func operation<Request: Codable, Response: Codable>(_ request: Request) async throws -> Response {
        guard let url = URL(string: endpoint) else { throw WSDLOperationError.invalidEndpoint}
        let encoder = XMLEncoder()
        let requestEnvelope = SOAPEnvelope<Request>(body: request)
        let encoded = try encoder.encode(requestEnvelope, withRootKey: "soap:Envelope", rootAttributes: [
            "xmlns:soap": "http://schemas.xmlsoap.org/soap/envelope/",
            "xmlns:tns": targetNamespace,
            "xmlns:xsd": "http://www.w3.org/2001/XMLSchema",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        ])
        let soapRequest = try XMLDocument(data: encoded)
        self.soapRequest?(soapRequest.xmlString(options: .nodePrettyPrint))
        var request = authentication.createRequest(with: url)
        request.addValue("text/xml\(characterSet.specifier)", forHTTPHeaderField: "Content-Type")
        request.addValue("WSDL2Swift", forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = soapRequest.xmlData
        let (data, response) = try await URLSession.shared.data(for: request)

        let decoder = XMLDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.shouldProcessNamespaces = true

        switch (response as? HTTPURLResponse)?.statusCode {
        case 200:
            guard let doc = try? XMLDocument(data: data) else { throw WSDLOperationError.invalidResponseXML }
            self.soapResponse?(doc.xmlString(options: .nodePrettyPrint))
            return try decoder.decode(SOAPEnvelope<Response>.self, from: data).body
        case 401:
            throw WSDLOperationError.unauhtenticated
        case 500:
            throw WSDLOperationError.soapFault(try decoder.decode(SOAPEnvelope<Fault>.self, from: data).body)
        default:
            throw WSDLOperationError.invalidHTTPResponse(response)
        }
    }
}

public enum Authentication {
    case none
    case basic( username: String, password: String )

    public func createRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        switch self {
        case .basic(username: let username, password: let password):
            let loginString = String(format: "%@:%@", username, password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let basicAuthorization = loginData.base64EncodedString()
            request.addValue("Basic \(basicAuthorization)", forHTTPHeaderField: "Authorization")
        case .none: break
        }
        return request
    }
}
                              
public enum CharacterSet {
    case unspecified
    case manual( String )
    case utf8
    
    var specifier: String {
        switch self{
        case .unspecified: ""
        case .manual( let mimeName ): ";charset=\(mimeName)"
        case .utf8: ";charset=utf-8"
        }
    }
}

struct SOAPEnvelope<Body: Codable>: Codable {
    var body: Body
    
    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    public init(body: Body) {
        self.body = body
    }

    public init(from decoder: Decoder) throws {
        let envelope = try decoder.container(keyedBy: CodingKeys.self)
        let bodyContainerKey = CodingKeys(stringValue: "Body")!
        let bodyContainer = try envelope.nestedContainer(keyedBy: CodingKeys.self, forKey: bodyContainerKey)
        self.body = try bodyContainer.decode(Body.self, forKey: CodingKeys(stringValue: String(describing: Body.self))!)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var envelope = encoder.container(keyedBy: CodingKeys.self)
        let bodyContainerKey = CodingKeys(stringValue: "soap:Body")
        var bodyContainer = envelope.nestedContainer(keyedBy: CodingKeys.self, forKey: bodyContainerKey!)
        try bodyContainer.encode(body, forKey: CodingKeys(stringValue: "tns:\(String(describing: Body.self))")!)
    }
}

public struct Fault: Codable {
    public var faultcode: String
    public var faultstring: String
    public var faultactor: String?
    public var detail: String?
}

public enum WSDLOperationError: Error {
    case unauhtenticated
    case invalidEndpoint
    case invalidHTTPResponse(URLResponse)
    case invalidResponseXML
    case soapFault(Fault)
}
