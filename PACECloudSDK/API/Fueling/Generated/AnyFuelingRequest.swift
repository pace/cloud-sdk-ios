//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

public class AnyFuelingAPIRequest: FuelingAPIRequest<AnyResponseValue> {
    private let requestPath: String

    override public var path: String {
        return requestPath
    }

    init<T>(request: FuelingAPIRequest<T>) {
        requestPath = request.path
        super.init(service: request.service.asAny(), queryParameters: request.queryParameters, formParameters: request.formParameters, headers: request.headers, encodeBody: request.encodeBody)
    }
}

extension FuelingAPIRequest {
    public func asAny() -> AnyFuelingAPIRequest {
        return AnyFuelingAPIRequest(request: self)
    }
}