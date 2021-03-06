//
// Generated by SwiftPoet
// https://github.com/outfoxx/swiftpoet
//
import Foundation
import WebKit

extension API.Communication {
    class MessageHandler {
        private weak var delegate: CommunicationProtocol?
        private let requestTimeoutHandler: RequestTimeoutHandler = .init()
        private let decoder: JSONDecoder = .init()
        private let encoder: JSONEncoder = .init()

        init(delegate: CommunicationProtocol) {
            self.delegate = delegate
            requestTimeoutHandler.delegate = self
        }

        func handleAppMessage(_ message: WKScriptMessage) {
            guard
                let messageBody = message.body as? String,
                let messageBodyData = messageBody.data(using: .utf8),
                let request: Request = decode(messageBodyData),
                let id = request.id,
                let operationString = request.uri?.dropFirst(),
                let operation = Operation(rawValue: String(operationString))
            else {
                let error: Error = .init(message: "The message content is malformed. Possible reasons: a missing id, a wrong path name or content is not built as defined.")
                handleResult(with: .init(status: HttpStatusCode.badRequest.rawValue, body: .init(error)), response: .init(), operation: nil)
                return
            }

            let header = request.header
            let requestUrl = message.frameInfo.request.url
            let response = Response(id: id, header: header, status: nil, body: nil)

            let timeout: TimeInterval = header?[HttpHeaderFields.keepAlive.rawValue]?.value as? NSNumber as? TimeInterval ?? 5
            requestTimeoutHandler.scheduleTimer(with: id, timeout: timeout, operation: operation) { [weak self] in
                self?.determineOperation(operation, request: request, response: response, requestUrl: requestUrl)
            }
        }

        func determineOperation(_ operation: Operation, request: Request, response: Response, requestUrl: URL?) {
            switch operation {
            case .introspect:
                let result = introspectResult()
                handleResult(with: result, response: response, operation: operation)

            case .close:
                delegate?.handleClose { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .logout:
                delegate?.handleLogout { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getBiometricStatus:
                delegate?.handleGetBiometricStatus { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .setTOTP:
                guard let requestBody: SetTOTPRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleSetTOTP(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getTOTP:
                guard let requestBody: GetTOTPRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleGetTOTP(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .setSecureData:
                guard let requestBody: SetSecureDataRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleSetSecureData(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getSecureData:
                guard let requestBody: GetSecureDataRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleGetSecureData(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .disable:
                guard let requestBody: DisableRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleDisable(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .openURLInNewTab:
                guard let requestBody: OpenURLInNewTabRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleOpenURLInNewTab(with: requestBody, requestUrl: requestUrl) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .verifyLocation:
                guard let requestBody: VerifyLocationRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleVerifyLocation(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getAccessToken:
                guard let requestBody: GetAccessTokenRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleGetAccessToken(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .imageData:
                guard let requestBody: ImageDataRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleImageData(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .applePayAvailabilityCheck:
                guard let requestBody: ApplePayAvailabilityCheckRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleApplePayAvailabilityCheck(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .applePayRequest:
                guard let requestBody: ApplePayRequestRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleApplePayRequest(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .back:
                delegate?.handleBack { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .appInterceptableLink:
                delegate?.handleAppInterceptableLink { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .setUserProperty:
                guard let requestBody: SetUserPropertyRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleSetUserProperty(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .logEvent:
                guard let requestBody: LogEventRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleLogEvent(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getConfig:
                guard let requestBody: GetConfigRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleGetConfig(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getTraceId:
                delegate?.handleGetTraceId { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .getLocation:
                delegate?.handleGetLocation { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .appRedirect:
                guard let requestBody: AppRedirectRequest = decodeRequestBody(request, response, operation) else { return }
                delegate?.handleAppRedirect(with: requestBody) { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }

            case .isBiometricAuthEnabled:
                delegate?.handleIsBiometricAuthEnabled { [weak self] result in
                    self?.handleResult(with: result, response: response, operation: operation)
                }
            }
        }

        private func introspectResult() -> IntrospectResult {
            let operations: [String] = Operation.allCases.filter({ $0 != .introspect }).map({ "/\($0.rawValue)" })
            return .init(.init(response: .init(version: "v1", operations: operations)))
        }

        private func handleResult(with result: Result, response: Response, operation: Operation?) {
            response.status = result.status
            response.body = result.body
            sendResponse(with: response, operation: operation)
        }

        private func decodeRequestBody<T : Decodable>(_ request: Request, _ response: Response, _ operation: Operation) -> T? {
            guard
                let body = request.body?.value,
                let bodyData = try? JSONSerialization.data(withJSONObject: body),
                let requestBody: T = decode(bodyData)
            else {
                let error: Error = .init(message: "The request body couldn't be parsed.")
                handleResult(with: .init(status: HttpStatusCode.internalError.rawValue, body: .init(error)), response: response, operation: operation)
                return nil
            }
            return requestBody
        }

        private func sendResponse(with response: Response, operation: Operation?) {
            respond(with: response)
            if let id = response.id {
                requestTimeoutHandler.stopTimer(with: id, operation: operation)
            }
        }

        private func respond(with response: Response) {
            guard let response = encode(response) else { return }
            delegate?.respond(with: response)
        }

        private func decode<T : Decodable>(_ data: Data) -> T? {
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                Logger.e("Failed parsing \(T.self) with error \(error)")
                return nil
            }
        }

        private func encode(_ response: Response) -> String? {
            do {
                let jsonData = try encoder.encode(response)
                let result = String(data: jsonData, encoding: .utf8)
                return result
            } catch {
                Logger.e("Failed encoding response with error \(error)")
                return nil
            }
        }
    }
}

extension API.Communication.MessageHandler: RequestTimeoutHandlerDelegate {
    func didReachTimeout(_ requestId: String) {
        let error = API.Communication.Error(message: "The request timed out.")
        let response = API.Communication.Response(id: requestId, header: nil, status: HttpStatusCode.requestTimeout.rawValue, body: .init(error))
        respond(with: response)
    }
}
