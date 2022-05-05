import Foundation
import Combine

struct NetworkCallAgent {
    // RT: return type in generic form
    func dispatchApi<RT: Codable>(request: URLRequest) -> AnyPublisher<RT, APICallError> {
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    debugPrint(String(data: try
                                 JSONSerialization.data(withJSONObject: JSONSerialization.jsonObject(with: data, options: []),
                                                        options: .prettyPrinted), encoding: .utf8)!)
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Int] {
                        debugPrint(json)
                    }
                } catch let error as NSError {
                    debugPrint(data)
                    debugPrint("Failed to load: \(error.localizedDescription)")
                }
                 
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APICallError.invalidResponse
                }
                guard httpResponse.statusCode == 200 || httpResponse.statusCode == 400 || httpResponse.statusCode == 404 || httpResponse.statusCode == 401 || httpResponse.statusCode == 500 else {
                    throw httpError(httpResponse.statusCode)
                }
                return data
            }
            .decode(type: RT.self, decoder: JSONDecoder())
            .mapError { error in
                handleError(error)
            }
            .eraseToAnyPublisher()
    }
    
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int) -> APICallError {
        switch statusCode {
        case 400: return .badRequest
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 402, 405...499: return .error4xx(statusCode)
        case 500: return .serverError
        case 501...599: return .error5xx(statusCode)
        default: return .unknownError
        }
    }
    
    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func handleError(_ error: Error) -> APICallError {
        switch error {
        case is Swift.DecodingError:
            return .decoding
        case let urlError as URLError:
            switch URLError.Code(rawValue: urlError.code.rawValue) {
            case .notConnectedToInternet:
                return APICallError.noInternet
            default:
                return .urlSessionFailed(urlError)
            }
        case let error as APICallError:
            return error
        default:
            return .unknownError
        }
    }
    
}
