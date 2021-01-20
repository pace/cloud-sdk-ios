//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

public class AnyPOIAPIRequest: POIAPIRequest<AnyResponseValue> {
    private let requestPath: String

    override public var path: String {
        return requestPath
    }

    init<T>(request: POIAPIRequest<T>) {
        requestPath = request.path
        super.init(service: request.service.asAny(), queryParameters: request.queryParameters, formParameters: request.formParameters, headers: request.headers, encodeBody: request.encodeBody)
    }
}

extension POIAPIRequest {
    public func asAny() -> AnyPOIAPIRequest {
        return AnyPOIAPIRequest(request: self)
    }
}
