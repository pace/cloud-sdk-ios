//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

public class AnyPayAPIRequest: PayAPIRequest<AnyResponseValue> {
    private let requestPath: String

    override public var path: String {
        return requestPath
    }

    init<T>(request: PayAPIRequest<T>) {
        requestPath = request.path
        super.init(service: request.service.asAny(), queryParameters: request.queryParameters, formParameters: request.formParameters, headers: request.headers, encodeBody: request.encodeBody)
    }
}

extension PayAPIRequest {
    public func asAny() -> AnyPayAPIRequest {
        return AnyPayAPIRequest(request: self)
    }
}
