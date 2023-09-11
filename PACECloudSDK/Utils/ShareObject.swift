//
//  ShareObject.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import LinkPresentation
import UIKit

class ShareObject: NSObject, UIActivityItemSource {

    private let shareData: Any
    private let customTitle: String?

    required init(shareData: Any, customTitle: String? = nil) {
        self.shareData = shareData
        self.customTitle = customTitle
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return shareData
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return shareData
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        guard let customTitle = customTitle else { return nil }
        let metadata = LPLinkMetadata()
        metadata.title = customTitle
        return metadata
    }
}
